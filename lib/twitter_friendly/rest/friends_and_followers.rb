require 'parallel'

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
        args << options

        if options.has_key?(:cursor)
          @twitter.friend_ids(*args)&.attrs
        else
          fetch_resources_with_cursor(__method__, *args)
        end
      end

      def follower_ids(*args)
        options = {count: MAX_IDS_PER_REQUEST}.merge(args.extract_options!)
        args << options

        if options.has_key?(:cursor)
          @twitter.follower_ids(*args)&.attrs
        else
          fetch_resources_with_cursor(__method__, *args)
        end
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
        ids = friend_ids(*args)
        users(ids)
      end

      def followers(*args)
        ids = follower_ids(*args)
        users(ids)
      end

      def friend_ids_and_follower_ids(*args)
        parallel(in_threads: 2) do |batch|
          batch.friend_ids(*args)
          batch.follower_ids(*args)
        end
      end

      def friends_and_followers(*args)
        following_ids, followed_ids = friend_ids_and_follower_ids(*args)
        people = users((following_ids + followed_ids).uniq).index_by { |u| u[:id] }
        [people.slice(*following_ids).values, people.slice(*followed_ids).values]
      end
    end
  end
end
