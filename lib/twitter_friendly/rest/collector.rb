module TwitterFriendly
  module REST
    module Collector
      def fetch_tweets_with_max_id(method_name, max_count, user, options)
        total_count = options.delete(:count) || max_count
        call_count = total_count / max_count + (total_count % max_count == 0 ? 0 : 1)
        options[:count] = [max_count, total_count].min
        collect_options = {call_count: call_count, total_count: total_count}

        collect_with_max_id(user, [], nil, options, collect_options) do |max_id|
          options[:max_id] = max_id unless max_id.nil?
          result = send(method_name, *[user, options].compact)

          if method_name == :search
            result.attrs[:statuses]
          else
            if result.is_a?(Array) && result[0].respond_to?(:attrs)
              result.map(&:attrs)
            else
              result
            end
          end
        end
      end

      # @param method_name [Symbol]
      # @param user [Integer, String, nil]
      #
      # @option options [Integer] :count
      def fetch_resources_with_cursor(method_name, *args)
        options = args.dup.extract_options!

        collect_with_cursor([], -1) do |next_cursor|
          options[:cursor] = next_cursor unless next_cursor.nil?
          send(method_name, *args)
        end
      end

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
      def collect_with_cursor(collection, cursor, &block)
        response = yield(cursor)
        return collection if response.nil?

        # Notice: If you call response.to_a, it automatically fetch all results and the results are not cached.
        collection.concat (response[:ids] || response[:users] || response[:lists])
        response[:next_cursor].zero? ? collection.flatten : collect_with_cursor(collection, response[:next_cursor], &block)
      end
    end
  end
end