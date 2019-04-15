require 'parallel'

module TwitterFriendly
  module REST
    module Users
      def verify_credentials(include_entities: false, skip_status: true, include_email: true)
        @twitter.verify_credentials(include_entities: include_entities, skip_status: skip_status, include_email: include_email)&.to_hash
      end

      def user?(*args)
        @twitter.user?(*args)
      end

      def user(*args)
        @twitter.user(*args)&.to_hash
      end

      MAX_USERS_PER_REQUEST = 100

      def users(values, options = {})
        if values.size <= MAX_USERS_PER_REQUEST
          @twitter.users(values, options).map(&:to_h)
        else
          parallel(in_threads: 6) do |batch|
            values.each_slice(MAX_USERS_PER_REQUEST) { |targets| batch.users(targets, options) }
          end.flatten
        end
      end

      def blocked_ids(*args)
        @twitter.blocked_ids(*args)&.attrs&.fetch(:ids)
      end
    end
  end
end
