module TwitterFriendly
  module REST
    module Collector
      def collect_with_max_id(collection = [], max_id = nil, &block)
        tweets = nil
        Instrumenter.perform_collect_with_max_id(args: [__method__, max_id: max_id]) do
          tweets = yield(max_id)
        end
        return collection if tweets.nil?
        collection += tweets
        tweets.empty? ? collection.flatten : collect_with_max_id(collection, tweets.last.id - 1, &block)
      end

      def collect_with_cursor(collection = [], cursor = nil, &block)
        response = nil
        Instrumenter.perform_collect_with_max_id(args: [__method__, cursor: cursor]) do
          response = yield(cursor)
        end
        return collection if response.nil?

        # Notice: If you call response.to_a, it automatically fetch all results and the results are not cached.
        collection += (response.attrs[:ids] || response.attrs[:users] || response.attrs[:lists])
        response.attrs[:next_cursor].zero? ? collection.flatten : collect_with_cursor(collection, response.attrs[:next_cursor], &block)
      end
    end

    module Instrumenter

      module_function

      def perform_collect_with_max_id(options, &block)
        payload = {operation: 'collect', args: options[:args]}
        ::ActiveSupport::Notifications.instrument('collect.twitter_friendly', payload) { yield(payload) }
      end

      def perform_collect_with_cursor(options, &block)
        payload = {operation: 'collect', args: options[:args]}
        ::ActiveSupport::Notifications.instrument('collect.twitter_friendly', payload) { yield(payload) }
      end
    end
  end
end