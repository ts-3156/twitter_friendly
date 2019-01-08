module TwitterFriendly
  module REST
    module Base
      def fetch_tweets_with_max_id(name, args, max_count)
        options = args.extract_options!
        total_count = options.delete(:count) || max_count
        call_count = total_count / max_count + (total_count % max_count == 0 ? 0 : 1)
        options[:count] = max_count

        collect_with_max_id(args[0], [], nil, {super_operation: name}.merge(options)) do |max_id|
          options[:max_id] = max_id unless max_id.nil?
          if (call_count -= 1) >= 0
            if name == :search
              @twitter.send(name, *args, options).attrs[:statuses]
            else
              @twitter.send(name, *args, options).map(&:attrs)
            end
          end
        end
      end

      def fetch_resources_with_cursor(name, args)
        options = args.extract_options!

        collect_with_cursor(args[0], [], -1, {super_operation: name}.merge(options)) do |next_cursor|
          options[:cursor] = next_cursor unless next_cursor.nil?
          @twitter.send(name, *args, options)
        end
      end
    end
  end
end