module TwitterFriendly
  module REST
    module Lists

      MAX_LISTS_PER_REQUEST = 1000

      # @return [Hash] The lists the specified user has been added to.
      #
      # @overload list_members(options = {})
      # @overload list_members(user, options = {})
      #
      # @param user [Integer, String] A Twitter user ID or screen name.
      #
      # @option options [Integer] :count The number of tweets to return per page, up to a maximum of 5000.
      def memberships(*args)
        options = {count: MAX_LISTS_PER_REQUEST}.merge(args.extract_options!)
        push_operations(options, __method__)
        fetch_resources_with_cursor(__method__, args[0], options)
      end
      TwitterFriendly::Caching.logging :memberships

      MAX_MEMBERS_PER_REQUEST = 5000

      # @return [Hash] The members of the specified list.
      #
      # @overload list_members(options = {})
      # @overload list_members(user, options = {})
      #
      # @param list [Integer, String] A Twitter user ID or screen name.
      #
      # @option options [Integer] :count The number of tweets to return per page, up to a maximum of 5000.
      def list_members(*args)
        options = {count: MAX_MEMBERS_PER_REQUEST, skip_status: 1}.merge(args.extract_options!)
        push_operations(options, __method__)
        fetch_resources_with_cursor(__method__, args[0], options)
      end
      TwitterFriendly::Caching.logging :list_members
    end
  end
end
