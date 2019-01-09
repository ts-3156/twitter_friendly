require 'forwardable'

require 'twitter_friendly/caching'
require 'twitter_friendly/rest/api'

module TwitterFriendly
  class Client
    extend Forwardable
    def_delegators :@twitter, :access_token, :access_token_secret, :consumer_key, :consumer_secret

    include TwitterFriendly::REST::API
    include TwitterFriendly::RateLimit

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
