module TwitterFriendly
  module REST
    module Collector
      def collect_with_max_id(user, collection, max_id, options, &block)
        fetch_options = options.dup
        fetch_options[:max_id] = max_id
        fetch_options.merge!(args: [__method__, fetch_options], hash: credentials_hash)

        # TODO Handle {cache: false} option
        tweets =
            @cache.fetch(__method__, user, fetch_options) do
              Instrumenter.perform_request(args: [__method__, max_id: max_id, super_operation: options[:super_operation]]) do
                yield(max_id)
              end
            end
        return collection if tweets.nil?

        options[:recursive] = true

        collection.concat tweets
        tweets.empty? ? collection.flatten : collect_with_max_id(user, collection, tweets.last[:id] - 1, options, &block)
      end

      def collect_with_cursor(user, collection, cursor, options, &block)
        fetch_options = options.dup
        fetch_options[:cursor] = cursor
        fetch_options.merge!(args: [__method__, fetch_options], hash: credentials_hash)

        # TODO Handle {cache: false} option
        response =
            @cache.fetch(__method__, user, fetch_options) do
              Instrumenter.perform_request(args: [__method__, cursor: cursor, super_operation: options[:super_operation]]) do
                yield(cursor).attrs
              end
            end
        return collection if response.nil?

        options[:recursive] = true

        # Notice: If you call response.to_a, it automatically fetch all results and the results are not cached.
        collection.concat (response[:ids] || response[:users] || response[:lists])
        response[:next_cursor].zero? ? collection.flatten : collect_with_cursor(user, collection, response[:next_cursor], options, &block)
      end

      module Instrumenter

        module_function

        # 他のメソッドと違い再帰的に呼ばれるため、全体をキャッシュすると、すべてを再帰的にキャッシュしてしまう。
        # それを防ぐために、特別にここでキャッシュの処理を登録している。

        def perform_request(options, &block)
          payload = {operation: 'collect', args: options[:args]}
          ::ActiveSupport::Notifications.instrument('collect.twitter_friendly', payload) { yield(payload) }
        end
      end

      module Caching
        %i(
          collect_with_max_id
          collect_with_cursor
        ).each do |name|
          define_method(name) do |*args, &block|
            options = args.extract_options!
            do_request = Proc.new { options.empty? ? super(*args, &block) : super(*args, options, &block) }

            if options[:recursive]
              do_request.call
            else
              TwitterFriendly::Caching::Instrumenter.start_processing(name, options)
              TwitterFriendly::Caching::Instrumenter.complete_processing(name, options, &do_request)
            end
          end
        end
      end
    end
  end
end