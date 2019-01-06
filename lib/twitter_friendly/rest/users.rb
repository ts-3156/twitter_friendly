module TwitterFriendly
  module REST
    module Users
      def verify_credentials(options = {})
        @twitter.send(__method__, {skip_status: true}.merge(options))&.to_hash
      end

      def user?(*args)
        @twitter.send(__method__, *args)
      end

      def user(*args)
        @twitter.send(__method__, *args)&.to_hash
      end

      MAX_USERS_PER_REQUEST = 100

      def users(values, options = {})
        if values.size <= MAX_USERS_PER_REQUEST
          @twitter.send(__method__, values, options)&.compact&.map(&:to_hash)
        else
          _users(values, options)
        end
      end

      def blocked_ids(*args)
        @twitter.send(__method__, *args)&.attrs&.fetch(:ids)
      end

      private

      def _users(values, options = {})
        options = {super_operation: :users, parallel: true}.merge(options)

        if options[:parallel]
          require 'parallel'

          parallel(in_threads: 10) do |batch|
            values.each_slice(MAX_USERS_PER_REQUEST) { |targets| batch.users(targets, options) }
          end.flatten
        else
          values.each_slice(MAX_USERS_PER_REQUEST).map do |targets|
            @twitter.send(:users, targets, options)
          end
        end&.flatten&.compact&.map(&:to_hash)
      end
    end
  end
end
