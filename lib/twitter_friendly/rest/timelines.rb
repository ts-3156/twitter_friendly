module TwitterFriendly
  module REST
    module Timelines

      MAX_TWEETS_PER_REQUEST = 200

      def home_timeline(options = {})
        options = {include_rts: true}.merge(options)
        push_operations(options, __method__)
        fetch_tweets_with_max_id(__method__, MAX_TWEETS_PER_REQUEST, nil, options)
      end

      def user_timeline(*args)
        options = {include_rts: true}.merge(args.extract_options!)
        push_operations(options, __method__)
        fetch_tweets_with_max_id(__method__, MAX_TWEETS_PER_REQUEST, args[0], options)
      end

      def mentions_timeline(options = {})
        options = {include_rts: true}.merge(options)
        push_operations(options, __method__)
        fetch_tweets_with_max_id(__method__, MAX_TWEETS_PER_REQUEST, nil, options)
      end
    end
  end
end
