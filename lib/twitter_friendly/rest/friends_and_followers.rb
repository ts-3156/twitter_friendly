module TwitterFriendly
  module REST
    module FriendsAndFollowers
      def friendship?(from, to, options = {})
        @twitter.send(__method__, from, to, options)
      end

      MAX_IDS_PER_REQUEST = 5000

      # @return [Hash]
      #
      # @overload friend_ids(options = {})
      # @overload friend_ids(user, options = {})
      #
      # @param user [Integer, String] A Twitter user ID or screen name.
      #
      # @option options [Integer] :count The number of tweets to return per page, up to a maximum of 5000.
      def friend_ids(*args)
        options = {count: MAX_IDS_PER_REQUEST}.merge(args.extract_options!)
        push_operations(options, __method__)
        fetch_resources_with_cursor(__method__, args[0], options)
      end

      def follower_ids(*args)
        options = {count: MAX_IDS_PER_REQUEST}.merge(args.extract_options!)
        push_operations(options, __method__)
        fetch_resources_with_cursor(__method__, args[0], options)
      end

      # @return [Hash]
      #
      # @overload friends(options = {})
      # @overload friends(user, options = {})
      #
      # @param user [Integer, String] A Twitter user ID or screen name.
      #
      # @option options [Bool] :parallel
      def friends(*args)
        options = {parallel: true}.merge(args.extract_options!)
        push_operations(options, __method__)
        ids = friend_ids(*args, options.except(:parallel))
        users(ids, options)
      end

      def followers(*args)
        options = {parallel: true}.merge(args.extract_options!)
        push_operations(options, __method__)
        ids = follower_ids(*args, options.except(:parallel))
        users(ids, options)
      end

      def friend_ids_and_follower_ids(*args)
        options = { parallel: true}.merge(args.extract_options!)
        is_parallel = options.delete(:parallel)

        if is_parallel
          require 'parallel'

          parallel(in_threads: 2) do |batch|
            batch.friend_ids(*args, options.merge(super_operation: [__method__]))
            batch.follower_ids(*args, options.merge(super_operation: [__method__]))
          end
        else
          [friend_ids(*args, options), follower_ids(*args, options)]
        end
      end

      def friends_and_followers(*args)
        options = args.extract_options!.merge(super_operation: :friends_and_followers)

        following_ids, followed_ids = friend_ids_and_follower_ids(*args, options)
        unique_ids = (following_ids + followed_ids).uniq
        people = _users(unique_ids).index_by { |u| u[:id] }
        [people.slice(*following_ids).values, people.slice(*followed_ids).values]

        # parallel(in_threads: 2) do |batch|
        #   batch.friends(*args, options)
        #   batch.followers(*args, options)
        # end
      end
    end
  end
end
