module TwitterFriendly
  module REST
    module Search

      MAX_TWEETS_PER_REQUEST = 100

      %i(search).each do |name|
        define_method(name) do |query, options = {}|
          raise ArgumentError.new('You must specify a search query.') unless query.is_a?(String)
          options = {result_type: :recent}.merge(options)
          push_operations(options, name)
          fetch_tweets_with_max_id(name, MAX_TWEETS_PER_REQUEST, query, options)
        end
      end
    end
  end
end