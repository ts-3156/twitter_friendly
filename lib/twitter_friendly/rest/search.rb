module TwitterFriendly
  module REST
    module Search

      MAX_TWEETS_PER_REQUEST = 100

      %i(search).each do |name|
        define_method(name) do |query, options = {}|
          raise ArgumentError.new('You must specify a search query.') unless query.is_a?(String)

          total_count = options.delete(:count) || MAX_TWEETS_PER_REQUEST
          call_count = total_count / MAX_TWEETS_PER_REQUEST + (total_count % MAX_TWEETS_PER_REQUEST == 0 ? 0 : 1)
          options = {result_type: :recent}.merge(options)
          options[:count] = MAX_TWEETS_PER_REQUEST

          collect_with_max_id do |max_id|
            options[:max_id] = max_id unless max_id.nil?
            if (call_count -= 1) >= 0
              @twitter.send(name, query, options).attrs[:statuses].map { |s| Twitter::Tweet.new(s) }
            end
          end.map(&:attrs)
        end
      end
    end
  end
end