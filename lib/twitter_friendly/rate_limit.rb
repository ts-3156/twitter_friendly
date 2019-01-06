module TwitterFriendly
  module RateLimit
    def rate_limit
      RateLimit.new(perform_get('/1.1/application/rate_limit_status.json'))
    rescue => e
      logger.warn e.inspect
      nil
    end

    private

    def perform_get(*args)
      internal_client.send(:perform_get, *args)
    end

    class RateLimit
      def initialize(status)
        @status = status
      end

      def resources
        @status[:resources]
      end

      def verify_credentials
        extract_remaining_and_reset_in(resources[:account][:'/account/verify_credentials'])
      end

      def friend_ids
        extract_remaining_and_reset_in(resources[:friends][:'/friends/ids'])
      end

      def follower_ids
        extract_remaining_and_reset_in(resources[:followers][:'/followers/ids'])
      end

      def users
        extract_remaining_and_reset_in(resources[:users][:'/users/lookup'])
      end

      def friends(parallel: true)
        if parallel
          {friend_ids: friend_ids, users: users}
        else
          extract_remaining_and_reset_in(resources[:friends][:'/friends/list'])
        end
      end

      def followers(parallel: true)
        if parallel
          {follower_ids: follower_ids, users: users}
        else
          extract_remaining_and_reset_in(resources[:followers][:'/followers/list'])
        end
      end

      def to_h
        {
          verify_credentials: verify_credentials,
          friend_ids: friend_ids,
          follower_ids: follower_ids,
          users: users
        }
      end

      def inspect
        'verify_credentials ' + verify_credentials.inspect +
          ' friend_ids ' + friend_ids.inspect +
          ' follower_ids ' + follower_ids.inspect +
          ' users ' + users.inspect
      end

      private

      def extract_remaining_and_reset_in(limit)
        {remaining: limit[:remaining], reset_in: (Time.at(limit[:reset]) - Time.now).round}
      end
    end
  end
end

