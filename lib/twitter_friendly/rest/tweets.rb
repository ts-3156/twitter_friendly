module TwitterFriendly
  module REST
    module Tweets

      MAX_IDS_PER_REQUEST = 100

      def retweeters_ids(*args)
        options = {count: MAX_IDS_PER_REQUEST, cursor: -1}.merge(args.extract_options!)

        collect_with_cursor do |next_cursor|
          options[:cursor] = next_cursor unless next_cursor.nil?
          @twitter.send(__method__, *args, options)
        end
      end
    end
  end
end
