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

      def fetch_resources_with_cursor(method_name, *args)
        options = args.dup.extract_options!

        collect_with_cursor([], -1) do |next_cursor|
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

      def collect_with_cursor(collection, cursor, &block)
        response = yield(cursor)
        return collection if response.nil?

        # Notice: If you call response.to_a, it automatically fetch all results and the results are not cached.

        # cursor でリクエストするメソッドは cursor ごとキャッシュに保存するので、このメソッドで
        # ids, users または lists でリソースを取得する必要がある。
        collection.concat(response[:ids] || response[:users] || response[:lists])

        if response[:next_cursor].zero?
          collection.flatten
        else
          collect_with_cursor(collection, response[:next_cursor], &block)
        end
      end
    end
  end
end