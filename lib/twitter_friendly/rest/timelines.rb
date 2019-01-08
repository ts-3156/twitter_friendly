module TwitterFriendly
  module REST
    module Timelines

      MAX_TWEETS_PER_REQUEST = 200

      %i(home_timeline user_timeline mentions_timeline).each do |name|
        define_method(name) do |*args|
          args << {include_rts: true}.merge(args.extract_options!)
          fetch_tweets_with_max_id(name, args, MAX_TWEETS_PER_REQUEST)
        end
      end
    end
  end
end
