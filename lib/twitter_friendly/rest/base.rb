module TwitterFriendly
  module REST
    module Base
      def fetch_tweets_with_max_id(method_name, max_count, user, options)
        total_count = options.delete(:count) || max_count
        call_count = total_count / max_count + (total_count % max_count == 0 ? 0 : 1)
        options[:count] = [max_count, total_count].min
        collect_options = {call_count: call_count, total_count: total_count}

        collect_with_max_id(user, [], nil, options.merge(super_operation: method_name), collect_options) do |max_id|
          options[:max_id] = max_id unless max_id.nil?

          result = @twitter.send(method_name, *[user, options].compact)
          (method_name == :search) ? result.attrs[:statuses] : result.map(&:attrs)
        end
      end

      # @param method_name [Symbol]
      # @param user [Integer, String, nil]
      #
      # @option options [Integer] :count
      def fetch_resources_with_cursor(method_name, user, options)
        collect_with_cursor(user, [], -1, options.merge(super_operation: method_name)) do |next_cursor|
          options[:cursor] = next_cursor unless next_cursor.nil?
          @twitter.send(method_name, user, options)
        end
      end
    end
  end
end