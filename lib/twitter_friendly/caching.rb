module TwitterFriendly
  module Caching

    module_function

    # TODO 1つのメソッドに対して1回しか実行されないようにする
    # 全体をキャッシュさせ、さらにロギングを行う
    def caching(name)
      define_method(name) do |*args|
        options = args.extract_options!
        Instrumenter.start_processing(name, options)

        Instrumenter.complete_processing(name, options) do
          do_request =
              Proc.new {Instrumenter.perform_request(name, options) {options.empty? ? super(*args) : super(*args, options)}}

          if Utils.cache_disabled?(options)
            do_request.call
          else
            user = (name == :friendship?) ? args[0, 2] : args[0]
            key = CacheKey.gen(name, user, options.merge(hash: credentials_hash))
            @cache.fetch(key, args: [name, options], &do_request)
          end
        end
      end
    end

    # 全体をキャッシュせずにロギングだけを行う
    def logging(name)
      define_method(name) do |*args|
        options = args.extract_options!
        Instrumenter.start_processing(name, options)

        Instrumenter.complete_processing(name, options) do
          options.empty? ? super(*args) : super(*args, options)
        end
      end
    end

    module Instrumenter

      module_function

      def start_processing(operation, options)
        payload = {operation: operation}.merge(options)
        ::ActiveSupport::Notifications.instrument('start_processing.twitter_friendly', payload) {}
      end

      def complete_processing(operation, options)
        payload = {operation: operation}.merge(options)
        ::ActiveSupport::Notifications.instrument('complete_processing.twitter_friendly', payload) { yield(payload) }
      end

      def perform_request(caller, options, &block)
        payload = {operation: 'request', args: [caller, options]}
        ::ActiveSupport::Notifications.instrument('request.twitter_friendly', payload) { yield(payload) }
      end
    end

    module Utils

      module_function

      def cache_disabled?(options)
        options.is_a?(Hash) && options.has_key?(:cache) && !options[:cache]
      end
    end
  end
end