module TwitterFriendly
  module REST
    module Collector
      def collect_with_max_id(user, collection, max_id, options, collect_options, &block)
        key = CacheKey.gen(__method__, [user, options.merge(max_id: max_id)], hash: credentials_hash)

        tweets =
            @cache.fetch(key, args: [__method__, options]) do
              Instrumenter.perform_request(__method__, options) {yield(max_id)}
            end
        return collection if tweets.nil?

        collection.concat tweets
        if tweets.empty? || (collect_options[:call_count] -= 1) < 1
          collection.flatten
        else
          options[:recursive] = true
          collect_with_max_id(user, collection, tweets.last[:id] - 1, options, collect_options, &block)
        end
      end

      # @param user [Integer, String, nil]
      # @param collection [Array]
      # @param cursor [Integer]
      #
      # @option options [Integer] :count
      def collect_with_cursor(user, collection, cursor, options, &block)
        key = CacheKey.gen(__method__, [user, options.merge(cursor: cursor)], hash: credentials_hash)

        response =
            @cache.fetch(key, args: [__method__, options]) do
              Instrumenter.perform_request(__method__, options) {yield(cursor).attrs}
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

        def perform_request(method_name, options, &block)
          payload = {operation: 'collect', args: [method_name, options.slice(:max_id, :cursor)]}
          ::ActiveSupport::Notifications.instrument('collect.twitter_friendly', payload) { yield(payload) }
        end
      end

      module Caching
        %i(
          collect_with_max_id
          collect_with_cursor
        ).each do |name|
          define_method(name) do |*args, &block|
            options = args.dup.extract_options!
            do_request = Proc.new { super(*args, &block) }

            if options[:recursive]
              do_request.call
            else
              TwitterFriendly::CachingAndLogging::Instrumenter.start_processing(name, options)
              TwitterFriendly::CachingAndLogging::Instrumenter.complete_processing(name, options) {super(*args, &block)}
            end
          end
        end
      end
    end
  end
end