module TwitterFriendly
  module REST
    module Timelines

      MAX_TWEETS_PER_REQUEST = 200

      def home_timeline(options = {})
        options = {include_rts: true, count: MAX_TWEETS_PER_REQUEST}.merge(options)
        if options[:count] <= MAX_TWEETS_PER_REQUEST
          @twitter.home_timeline(options)
        else
          fetch_tweets_with_max_id(__method__, MAX_TWEETS_PER_REQUEST, nil, options)
        end
      end

      def user_timeline(*args)
        options = {include_rts: true, count: MAX_TWEETS_PER_REQUEST}.merge(args.extract_options!)
        if options[:count] <= MAX_TWEETS_PER_REQUEST
          @twitter.user_timeline(*args, options)
        else
          fetch_tweets_with_max_id(__method__, MAX_TWEETS_PER_REQUEST, args[0], options)
        end
      end

      def mentions_timeline(options = {})
        options = {include_rts: true, count: MAX_TWEETS_PER_REQUEST}.merge(options)
        if options[:count] <= MAX_TWEETS_PER_REQUEST
          @twitter.mentions_timeline(options)
        else
          fetch_tweets_with_max_id(__method__, MAX_TWEETS_PER_REQUEST, nil, options)
        end
      end

      module CachingTimelines
        # 他のメソッドと違い再帰的に呼ばれるため、全体をキャッシュすると、すべてを再帰的にキャッシュしてしまう。
        # それを防ぐために、特別にここでキャッシュの処理を登録している。
        def caching_timelines
          %i(home_timeline user_timeline mentions_timeline).each do |method_name|
            define_method(method_name) do |*args|
              options = {include_rts: true, count: MAX_TWEETS_PER_REQUEST}.merge(args.extract_options!)
              args << options

              if options[:count] <= MAX_TWEETS_PER_REQUEST
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
    end
  end
end
