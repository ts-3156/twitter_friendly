require 'forwardable'

require 'twitter_friendly/caching_and_logging'
require 'twitter_friendly/caching'
require 'twitter_friendly/rest/api'
require 'twitter_friendly/utils'

module TwitterFriendly
  class Client
    extend Forwardable
    def_delegators :@twitter, :access_token, :access_token_secret, :consumer_key, :consumer_secret

    include TwitterFriendly::Utils
    include TwitterFriendly::REST::API
    include TwitterFriendly::RateLimit

    extend TwitterFriendly::CachingAndLogging
    caching :user, :friendship?, :verify_credentials, :user?, :blocked_ids
    logging :friends, :followers, :friend_ids_and_follower_ids, :friends_and_followers, :retweeters_ids


    extend TwitterFriendly::Caching
    caching_users
    caching_tweets_with_max_id :home_timeline, :user_timeline, :mentions_timeline, :favorites, :search
    caching_resources_with_cursor :friend_ids, :follower_ids, :memberships, :list_members

    def initialize(*args)
      options = args.extract_options!

      @twitter = Twitter::REST::Client.new(options.slice(:access_token, :access_token_secret, :consumer_key, :consumer_secret))
      options.except!(:access_token, :access_token_secret, :consumer_key, :consumer_secret)

      @cache = TwitterFriendly::Cache.new(options.slice(:cache_dir, :expires_in, :race_condition_ttl))
      options.except!(:cache_dir, :expires_in, :race_condition_ttl)

      @logger = TwitterFriendly::Logger.new(options.slice(:log_dir, :log_level))

      unless subscriber_attached?
        if @logger.level == ::Logger::DEBUG
          @@subscriber_attached = true
          TwitterFriendly::Logging.logger = @logger
          TwitterFriendly::TFLogSubscriber.attach_to :twitter_friendly
          TwitterFriendly::ASLogSubscriber.attach_to :active_support
        end
      end
    end

    def cache
      @cache
    end

    def logger
      @logger
    end

    def internal_client
      @twitter
    end

    def twitter
      logger.warn "DEPRECATION WARNING: Use #internal_client instead of #twitter"
      internal_client
    end

    def subscriber_attached?
      @@subscriber_attached ||= false
    end
  end

  def cache(cache_dir = nil)
    TwitterFriendly::Cache.new(cache_dir: cache_dir)
  end
  module_function :cache
end
