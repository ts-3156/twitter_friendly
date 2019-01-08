module TwitterFriendly
  module REST
    module Lists

      MAX_LISTS_PER_REQUEST = 1000

      # Returns the lists the specified user has been added to.
      def memberships(*args)
        options = {count: MAX_LISTS_PER_REQUEST, cursor: -1}.merge(args.extract_options!)

        collect_with_cursor(args[0], [], -1, super_operation: __method__) do |next_cursor|
          options[:cursor] = next_cursor unless next_cursor.nil?
          @twitter.send(:memberships, *args, options)
        end
      end

      MAX_MEMBERS_PER_REQUEST = 5000

      # Returns the members of the specified list.
      def list_members(*args)
        options = {count: MAX_MEMBERS_PER_REQUEST, skip_status: 1, cursor: -1}.merge(args.extract_options!)

        collect_with_cursor(args[0], [], -1, super_operation: __method__) do |next_cursor|
          options[:cursor] = next_cursor unless next_cursor.nil?
          @twitter.send(:list_members, *args, options)
        end
      end
    end
  end
end
