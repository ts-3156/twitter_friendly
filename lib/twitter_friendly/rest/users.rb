require 'parallel'

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
          @twitter.users(values, options)
        else
          parallel(in_threads: 10) do |batch|
            values.each_slice(MAX_USERS_PER_REQUEST) { |targets| batch.users(targets, options) }
          end.flatten
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

      module CachingUsers
        def caching_users
          method_name = :users
          alias_method "orig_#{method_name}", method_name

          define_method(method_name) do |*args|
            if args[0].size <= MAX_USERS_PER_REQUEST
              options = args.dup.extract_options!
              Instrumenter.start_processing(method_name, options)

              Instrumenter.complete_processing(method_name, options) do

                key = CacheKey.gen(method_name, args, hash: credentials_hash)
                @cache.fetch(key, args: [method_name, options]) do
                  Instrumenter.perform_request(method_name, options) {send("orig_#{method_name}", *args)}
                end
              end
            else
              send("orig_#{method_name}", *args)
            end
          end
        end
      end
    end
  end
end
