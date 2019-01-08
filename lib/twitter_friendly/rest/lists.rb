module TwitterFriendly
  module REST
    module Lists

      MAX_LISTS_PER_REQUEST = 1000

      # Returns the lists the specified user has been added to.
      def memberships(*args)
        args << {count: MAX_LISTS_PER_REQUEST}.merge(args.extract_options!)
        fetch_resources_with_cursor(__method__, args)
      end

      MAX_MEMBERS_PER_REQUEST = 5000

      # Returns the members of the specified list.
      def list_members(*args)
        args << {count: MAX_MEMBERS_PER_REQUEST, skip_status: 1}.merge(args.extract_options!)
        fetch_resources_with_cursor(__method__, args)
      end
    end
  end
end
