require 'active_support'
require 'active_support/core_ext'
require 'twitter'

require "twitter_friendly/version"
require "twitter_friendly/utils"
require "twitter_friendly/logger"
require "twitter_friendly/serializer"
require "twitter_friendly/cache"
require "twitter_friendly/client"

module TwitterFriendly
  class Error < StandardError; end
  # Your code goes here...
end
