module TwitterFriendly
  module REST
    module Timelines

      MAX_TWEETS_PER_REQUEST = 200

      def home_timeline(options = {})
        options = {include_rts: true, count: MAX_TWEETS_PER_REQUEST}.merge(options)
        if options[:count] <= MAX_TWEETS_PER_REQUEST
          @twitter.home_timeline(options)&.map(&:attrs)
        else
          fetch_tweets_with_max_id(__method__, MAX_TWEETS_PER_REQUEST, options)
        end
      end

      def user_timeline(*args)
        options = {include_rts: true, count: MAX_TWEETS_PER_REQUEST}.merge(args.extract_options!)
        args << options
        if options[:count] <= MAX_TWEETS_PER_REQUEST
          @twitter.user_timeline(*args)&.map(&:attrs)
        else
          fetch_tweets_with_max_id(__method__, MAX_TWEETS_PER_REQUEST, *args)
        end
      end

      def mentions_timeline(options = {})
        options = {include_rts: true, count: MAX_TWEETS_PER_REQUEST}.merge(options)
        if options[:count] <= MAX_TWEETS_PER_REQUEST
          @twitter.mentions_timeline(options)&.map(&:attrs)
        else
          fetch_tweets_with_max_id(__method__, MAX_TWEETS_PER_REQUEST, options)
        end
      end
    end
  end
end
