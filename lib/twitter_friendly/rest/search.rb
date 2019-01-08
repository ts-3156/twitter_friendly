module TwitterFriendly
  module REST
    module Search

      MAX_TWEETS_PER_REQUEST = 100

      %i(search).each do |name|
        define_method(name) do |query, options = {}|
          raise ArgumentError.new('You must specify a search query.') unless query.is_a?(String)
          args = [query, {result_type: :recent}.merge(options)]
          fetch_tweets_with_max_id(name, args, MAX_TWEETS_PER_REQUEST)
        end
      end
    end
  end
end