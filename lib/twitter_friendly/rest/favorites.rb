module TwitterFriendly
  module REST
    module Favorites

      MAX_TWEETS_PER_REQUEST = 100

      def favorites(*args)
        options = {result_type: :recent}.merge(args.extract_options!)
        push_operations(options, __method__)
        fetch_tweets_with_max_id(__method__, MAX_TWEETS_PER_REQUEST, args[0], options)
      end
    end
  end
end
