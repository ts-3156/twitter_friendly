module TwitterFriendly
  module REST
    module Tweets

      MAX_IDS_PER_REQUEST = 100

      def retweeters_ids(*args)
        options = {count: MAX_IDS_PER_REQUEST}.merge(args.extract_options!)
        fetch_resources_with_cursor(__method__, args[0], options)
      end
    end
  end
end
