module TwitterFriendly
  module REST
    module Collector
      def collect_with_max_id(user, collection, max_id, options, collect_options, &block)
        tweets = yield(max_id)
        return collection if tweets.nil?

        collection.concat tweets
        if tweets.empty? || (collect_options[:call_count] -= 1) < 1
          collection.flatten
        else
          collect_with_max_id(user, collection, tweets.last[:id] - 1, options, collect_options, &block)
        end
      end

      # @param user [Integer, String, nil]
      # @param collection [Array]
      # @param cursor [Integer]
      #
      # @option options [Integer] :count
      def collect_with_cursor(user, collection, cursor, options, &block)
        response = Instrumenter.perform_request(__method__, options) {yield(cursor).attrs}
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
          payload = {operation: 'collect', args: [method_name, options.slice(:max_id, :cursor, :super_operation)]}
          ::ActiveSupport::Notifications.instrument('collect.twitter_friendly', payload) { yield(payload) }
        end
      end
    end
  end
end