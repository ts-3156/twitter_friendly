require 'forwardable'

require 'twitter_friendly/caching_and_logging'
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
    logging :favorites, :friend_ids, :follower_ids, :friends, :followers, :friend_ids_and_follower_ids, :friends_and_followers,
            :home_timeline, :user_timeline, :mentions_timeline, :search, :memberships, :list_members, :retweeters_ids

    def initialize(*args)
      options = args.extract_options!
      @twitter = Twitter::REST::Client.new(options.slice(:access_token, :access_token_secret, :consumer_key, :consumer_secret))

      options.except!(:access_token, :access_token_secret, :consumer_key, :consumer_secret)
      @cache = TwitterFriendly::Cache.new(options)

      @logger = TwitterFriendly::Logger.new(options)

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

    def subscriber_attached?
      @@subscriber_attached ||= false
    end
  end

  def cache(cache_dir = nil)
    TwitterFriendly::Cache.new(cache_dir: cache_dir)
  end
  module_function :cache
end
