module TwitterFriendly
  module REST
    module Tweets

      MAX_IDS_PER_REQUEST = 100

      # @return [Hash]
      #
      # @overload retweeters_ids(tweet, options = {})
      #
      # @param user [Integer, String] A Twitter user ID or screen name.
      #
      # @option options [Integer] :count The number of tweets to return per page, up to a maximum of 5000.
      def retweeters_ids(*args)
        # このメソッドではページングができない
        options = {count: MAX_IDS_PER_REQUEST}.merge(args.extract_options!)
        args << options
        @twitter.retweeters_ids(*args)
      end
    end
  end
end
