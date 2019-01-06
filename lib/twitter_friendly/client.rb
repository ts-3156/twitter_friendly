require 'forwardable'

require 'twitter_friendly/rest/api'

module TwitterFriendly
  class Client
    extend Forwardable
    def_delegators :@twitter, :perform_get, :access_token, :access_token_secret, :consumer_key, :consumer_secret

    include TwitterFriendly::REST::API

    def initialize(*args)
      options = args.extract_options!

      @cache = TwitterFriendly::Cache.new(options)
      @logger = TwitterFriendly::Logger.new(options)
      @twitter = Twitter::REST::Client.new(options)
    end
  end
end
