module TwitterFriendly
  module CachingAndLogging

    module_function

    # TODO 1つのメソッドに対して1回しか実行されないようにする
    # 全体をキャッシュさせ、さらにロギングを行う
    def caching(*method_names)
      method_names.each do |method_name|

        define_method(method_name) do |*args|
          options = args.dup.extract_options!
          Instrumenter.start_processing(method_name, options)

          Instrumenter.complete_processing(method_name, options) do

            key = CacheKey.gen(method_name, args, hash: credentials_hash)
            @cache.fetch(key, args: [method_name, options]) do
              Instrumenter.perform_request(method_name, options) {super(*args)}
            end
          end
        end
      end
    end

    # 全体をキャッシュせずにロギングだけを行う
    def logging(*root_args)
      root_args.each do |method_name|
        define_method(method_name) do |*args|
          options = args.dup.extract_options!
          Instrumenter.start_processing(method_name, options)

          Instrumenter.complete_processing(method_name, options) {super(*args)}
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
  end
end