module TwitterFriendly
  module REST
    module Collector
      def fetch_tweets_with_max_id(method_name, max_count, *args)
        options = args.dup.extract_options!

        total_count = options.delete(:count) || max_count
        call_count = total_count / max_count + (total_count % max_count == 0 ? 0 : 1)
        options[:count] = [max_count, total_count].min
        collect_options = {call_count: call_count, total_count: total_count}

        collect_with_max_id([], nil, collect_options) do |max_id|
          options[:max_id] = max_id unless max_id.nil?
          send(method_name, *args)
        end
      end

      def fetch_resources_with_cursor(method_name, max_count, *args)
        options = args.dup.extract_options!

        total_count = options.delete(:count) || max_count
        call_count = total_count / max_count + (total_count % max_count == 0 ? 0 : 1)
        options[:count] = [max_count, total_count].min
        collect_options = {call_count: call_count, total_count: total_count}

        collect_with_cursor([], -1, collect_options) do |next_cursor|
          options[:cursor] = next_cursor unless next_cursor.nil?
          send(method_name, *args)
        end
      end

      private

      def collect_with_max_id(collection, max_id, collect_options, &block)
        tweets = yield(max_id)

        if tweets.nil? || tweets.empty? || (collect_options[:call_count] -= 1) < 1
          collection.flatten
        else
          collection.concat(tweets)
          collect_with_max_id(collection, tweets.last[:id] - 1, collect_options, &block)
        end
      end

      def collect_with_cursor(collection, cursor, collect_options, &block)
        response = yield(cursor)
        if response.nil?
          logger.warn "#{__method__}: response is nil." if respond_to?(:logger)
          return collection
        end

        # Notice: If you call response.to_a, it automatically fetch all results and the results are not cached.

        # cursor でリクエストするメソッドは cursor ごとキャッシュに保存するので、このメソッドで
        # ids, users または lists でリソースを取得する必要がある。
        fetched_resources = response[:ids] || response[:users] || response[:lists]
        if fetched_resources.nil? || fetched_resources.empty?
          logger.warn "#{__method__}: fetched_resources is nil or empty." if respond_to?(:logger)
        end
        collection.concat(fetched_resources)

        if response[:next_cursor].zero? || (collect_options[:call_count] -= 1) < 1
          collection.flatten
        else
          collect_with_cursor(collection, response[:next_cursor], collect_options, &block)
        end
      end
    end
  end
end