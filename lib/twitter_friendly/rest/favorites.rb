module TwitterFriendly
  module REST
    module Favorites

      MAX_TWEETS_PER_REQUEST = 100

      %i(favorites).each do |name|
        define_method(name) do |*args|
          args << {result_type: :recent}.merge(args.extract_options!)
          fetch_tweets_with_max_id(name, args, MAX_TWEETS_PER_REQUEST)
        end
      end
    end
  end
end
