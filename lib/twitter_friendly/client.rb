require 'forwardable'

require 'twitter_friendly/rest/api'

module TwitterFriendly
  class Client
    extend Forwardable
    def_delegators :@twitter, :access_token, :access_token_secret, :consumer_key, :consumer_secret

    include TwitterFriendly::REST::API
    include TwitterFriendly::RateLimit

    def initialize(*args)
      options = args.extract_options!

      @cache = TwitterFriendly::Cache.new(options)
      @logger = TwitterFriendly::Logger.new(options)
      @twitter = Twitter::REST::Client.new(options)
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
  end

  def cache(cache_dir = nil)
    TwitterFriendly::Cache.new(cache_dir: cache_dir)
  end
  module_function :cache
end
