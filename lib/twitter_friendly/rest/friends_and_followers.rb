module TwitterFriendly
  module REST
    module FriendsAndFollowers
      def friendship?(from, to, options = {})
        @twitter.send(__method__, from, to, options)
      end

      MAX_IDS_PER_REQUEST = 5000

      %i(friend_ids follower_ids).each do |name|
        define_method(name) do |*args|
          raise ArgumentError.new('too many ids') if args[0].length > MAX_IDS_PER_REQUEST

          options = {count: MAX_IDS_PER_REQUEST, cursor: -1}.merge(args.extract_options!)

          collect_with_cursor do |next_cursor|
            options[:cursor] = next_cursor unless next_cursor.nil?
            @twitter.send(name, *args, options)
          end
        end
      end

      def friends(*args)
        options = args.extract_options!.merge(super_operation: :friends)
        ids = friend_ids(*args, options)
        _users(ids, options)
      end

      def followers(*args)
        options = args.extract_options!.merge(super_operation: :followers)
        ids = follower_ids(*args, options)
        _users(ids, options)
      end

      def friend_ids_and_follower_ids(*args)
        options = args.extract_options!.merge(super_operation: :friend_ids_and_follower_ids)

        parallel(in_threads: 2) do |batch|
          batch.friend_ids(*args, options)
          batch.follower_ids(*args, options)
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
