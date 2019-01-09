module TwitterFriendly
  module REST
    module Favorites

      MAX_TWEETS_PER_REQUEST = 100

      %i(favorites).each do |name|
        define_method(name) do |*args|
          options = {result_type: :recent}.merge(args.extract_options!)
          push_operations(options, name)
          fetch_tweets_with_max_id(name, MAX_TWEETS_PER_REQUEST, args[0], options)
        end
      end
    end
  end
end
