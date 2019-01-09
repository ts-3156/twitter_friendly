require 'twitter_friendly/rest/utils'
require 'twitter_friendly/rest/collector'
require "twitter_friendly/rest/parallel"
require "twitter_friendly/rest/base"
require 'twitter_friendly/rest/friends_and_followers'
require 'twitter_friendly/rest/users'
require 'twitter_friendly/rest/timelines'
require 'twitter_friendly/rest/search'
require 'twitter_friendly/rest/favorites'
require 'twitter_friendly/rest/lists'
require 'twitter_friendly/rest/tweets'

require 'twitter_friendly/caching'

module TwitterFriendly
  module REST
    module API
      include TwitterFriendly::REST::Utils
      include TwitterFriendly::REST::Collector
      include TwitterFriendly::REST::Parallel
      include TwitterFriendly::REST::Base
      include TwitterFriendly::REST::FriendsAndFollowers
      include TwitterFriendly::REST::Users
      include TwitterFriendly::REST::Timelines
      include TwitterFriendly::REST::Search
      include TwitterFriendly::REST::Favorites
      include TwitterFriendly::REST::Lists
      include TwitterFriendly::REST::Tweets

      include TwitterFriendly::Caching
      include TwitterFriendly::REST::Collector::Caching
      include TwitterFriendly::REST::Users::Caching
    end
  end
end
