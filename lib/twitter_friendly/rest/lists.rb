module TwitterFriendly
  module REST
    module Lists

      def list(*args)
        @twitter.list(*args)&.to_hash
      end

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
        args << options

        if options.has_key?(:cursor)
          @twitter.memberships(*args)&.attrs
        else
          fetch_resources_with_cursor(__method__, MAX_LISTS_PER_REQUEST, *args)
        end
      end

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
        args << options

        if options.has_key?(:cursor)
          @twitter.list_members(*args)&.attrs
        else
          fetch_resources_with_cursor(__method__, MAX_MEMBERS_PER_REQUEST, *args)
        end
      end
    end
  end
end
