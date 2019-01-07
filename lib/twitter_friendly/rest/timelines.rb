module TwitterFriendly
  module REST
    module Timelines

      MAX_TWEETS_PER_REQUEST = 200

      %i(home_timeline user_timeline mentions_timeline).each do |name|
        define_method(name) do |*args|
          options = args.extract_options!.merge(include_rts: true)
          total_count = options.delete(:count) || MAX_TWEETS_PER_REQUEST
          call_count = total_count / MAX_TWEETS_PER_REQUEST + (total_count % MAX_TWEETS_PER_REQUEST == 0 ? 0 : 1)
          count = 0
          options[count] = MAX_TWEETS_PER_REQUEST

          collect_with_max_id do |max_id|
            options[:max_id] = max_id unless max_id.nil?
            if (count += 1) <= call_count
              @twitter.send(name, *args, options)
            end
          end.map(&:attrs)
        end
      end
    end
  end
end
