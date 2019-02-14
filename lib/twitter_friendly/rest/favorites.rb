module TwitterFriendly
  module REST
    module Favorites

      MAX_TWEETS_PER_REQUEST = 100

      def favorites(*args)
        options = {count: MAX_TWEETS_PER_REQUEST}.merge(args.extract_options!)
        args << options

        if options[:count] <= MAX_TWEETS_PER_REQUEST
          @twitter.favorites(*args)&.map(&:attrs)
        else
          fetch_tweets_with_max_id(__method__, MAX_TWEETS_PER_REQUEST, *args)
        end
      end
    end
  end
end
