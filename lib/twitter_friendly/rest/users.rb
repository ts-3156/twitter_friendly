module TwitterFriendly
  module REST
    module Users
      def verify_credentials(options = {})
        @twitter.verify_credentials({skip_status: true}.merge(options))&.to_hash
      end

      def user?(user, options = {})
        @twitter.user?(user, options)
      end

      def user(*args)
        @twitter.user(*args)&.to_hash
      end

      MAX_USERS_PER_REQUEST = 100

      def users(values, options = {})
        if values.size <= MAX_USERS_PER_REQUEST
          key = CacheKey.gen(__method__, values, options.merge(hash: credentials_hash))

          @cache.fetch(key, args: [__method__, options]) do
            Instrumenter.perform_request(args: [__method__, super_operation: options[:super_operation]]) do
              @twitter.send(__method__, values, options.except(:parallel, :super_operation, :recursive))&.compact&.map(&:to_hash)
            end
          end
        else
          options[:recursive] = true
          _users(values, options)
        end
      end

      def blocked_ids(*args)
        @twitter.blocked_ids(*args)&.attrs&.fetch(:ids)
      end

      module Instrumenter

        module_function

        # 他のメソッドと違い再帰的に呼ばれるため、全体をキャッシュすると、すべてを再帰的にキャッシュしてしまう。
        # それを防ぐために、特別にここでキャッシュの処理を登録している。

        def perform_request(options, &block)
          payload = {operation: 'request', args: options[:args]}
          ::ActiveSupport::Notifications.instrument('request.twitter_friendly', payload) { yield(payload) }
        end
      end

      module Caching
        %i(
          users
        ).each do |name|
          define_method(name) do |*args, &block|
            options = args.extract_options!
            do_request = Proc.new { options.empty? ? super(*args, &block) : super(*args, options, &block) }

            if options[:recursive]
              do_request.call
            else
              TwitterFriendly::CachingAndLogging::Instrumenter.start_processing(name, options)
              TwitterFriendly::CachingAndLogging::Instrumenter.complete_processing(name, options, &do_request)
            end
          end
        end
      end

      private

      def _users(values, options = {})
        options = {super_operation: :users, parallel: true}.merge(options)

        if options[:parallel]
          require 'parallel'

          parallel(in_threads: 10) do |batch|
            values.each_slice(MAX_USERS_PER_REQUEST) { |targets| batch.users(targets, options) }
          end.flatten
        else
          values.each_slice(MAX_USERS_PER_REQUEST).map do |targets|
            users(targets, options)
          end
        end&.flatten&.compact&.map(&:to_hash)
      end
    end
  end
end
