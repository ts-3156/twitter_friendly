module TwitterFriendly
  module REST
    module Favorites

      MAX_TWEETS_PER_REQUEST = 100

      %i(favorites).each do |name|
        define_method(name) do |*args|
          options = {result_type: :recent}.merge(args.extract_options!)
          total_count = options.delete(:count) || MAX_TWEETS_PER_REQUEST
          call_count = total_count / MAX_TWEETS_PER_REQUEST + (total_count % MAX_TWEETS_PER_REQUEST == 0 ? 0 : 1)
          options[:count] = MAX_TWEETS_PER_REQUEST

          collect_with_max_id do |max_id|
            options[:max_id] = max_id unless max_id.nil?
            if (call_count -= 1) >= 0
              @twitter.send(name, *args, options)
            end
          end.map(&:attrs)
        end
      end
    end
  end
end
