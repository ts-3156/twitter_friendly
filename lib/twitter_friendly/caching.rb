module TwitterFriendly
  module Caching
    # 他のメソッドと違い再帰的に呼ばれるため、全体をキャッシュすると、すべてを再帰的にキャッシュしてしまう。
    # それを防ぐために、特別にここでキャッシュの処理を登録している。
    def caching_tweets_with_max_id(*method_names)
      method_names.each do |method_name|
        max_count =
            case method_name
            when :home_timeline     then TwitterFriendly::REST::Timelines::MAX_TWEETS_PER_REQUEST
            when :user_timeline     then TwitterFriendly::REST::Timelines::MAX_TWEETS_PER_REQUEST
            when :mentions_timeline then TwitterFriendly::REST::Timelines::MAX_TWEETS_PER_REQUEST
            when :favorites         then TwitterFriendly::REST::Favorites::MAX_TWEETS_PER_REQUEST
            when :search            then TwitterFriendly::REST::Search::MAX_TWEETS_PER_REQUEST
            else raise "Unknown method #{method_name}"
            end

        define_method(method_name) do |*args|
          options = {count: max_count}.merge(args.extract_options!)
          args << options

          if options[:count] <= max_count
            TwitterFriendly::CachingAndLogging::Instrumenter.start_processing(method_name, options)

            TwitterFriendly::CachingAndLogging::Instrumenter.complete_processing(method_name, options) do
              key = CacheKey.gen(method_name, args, hash: credentials_hash)
              @cache.fetch(key, args: [method_name, options]) do
                TwitterFriendly::CachingAndLogging::Instrumenter.perform_request(method_name, options) {super(*args)}
              end
            end
          else
            super(*args)
          end
        end
      end
    end

    def caching_resources_with_cursor(*method_names)
      method_names.each do |method_name|
        options = args.dup.extract_options!

        if options.has_key?(:cursor)
          TwitterFriendly::CachingAndLogging::Instrumenter.start_processing(method_name, options)

          TwitterFriendly::CachingAndLogging::Instrumenter.complete_processing(method_name, options) do
            key = CacheKey.gen(method_name, args, hash: credentials_hash)
            @cache.fetch(key, args: [method_name, options]) do
              TwitterFriendly::CachingAndLogging::Instrumenter.perform_request(method_name, options) {super(*args)}
            end
          end
        else
          super(*args)
        end
      end
    end
  end
end