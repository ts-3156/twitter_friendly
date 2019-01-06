module TwitterFriendly
  module Caching
    %i(
        verify_credentials
        user?
        user
        users
        blocked_ids
        home_timeline
        user_timeline
        mentions_timeline
        search
        favorites
        friendship?
        friend_ids
        follower_ids
        memberships
        list_members
      ).each do |name|
      define_method(name) do |*args|
        options = args.extract_options!

        Instrumenter.api_call(name, options) do
          do_request =
            proc { Instrumenter.perform_request(name, options) { options.empty? ? super(*args) : super(*args, options) } }

          if Utils.cache_disabled?(options)
            do_request.call
          else
            user = name == :friendship? ? args[0, 2] : args[0]
            @cache.fetch(name, user, options.merge(args: [name, options], hash: credentials_hash), &do_request)
          end
        end
      end
    end

    # Cached in #users
    %i(friends followers friends_and_followers).each do |name|
      define_method(name) do |*args|
        options = args.extract_options!
        Instrumenter.api_call(name, options) { super(*args, options) }
      end
    end

    module Instrumenter

      module_function

      def api_call(operation, options)
        payload = {operation: operation}.merge(options)
        ActiveSupport::Notifications.instrument('api_call.twitter', payload) { yield(payload) }
      end

      def perform_request(caller, options, &block)
        payload = {operation: 'request', args: [caller, options]}
        ActiveSupport::Notifications.instrument('request.twitter', payload) { yield(payload) }
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