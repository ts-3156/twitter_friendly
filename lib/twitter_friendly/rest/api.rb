require 'twitter_friendly/rest/utils'
require 'twitter_friendly/rest/collector'
require "twitter_friendly/rest/parallel"
require 'twitter_friendly/rest/friends_and_followers'
require 'twitter_friendly/rest/users'
require 'twitter_friendly/rest/timelines'
require 'twitter_friendly/rest/search'
require 'twitter_friendly/rest/favorites'
require 'twitter_friendly/rest/lists'
require 'twitter_friendly/rest/tweets'

# 後方互換性のために残した
require 'twitter_friendly/rest/extension/clusters'
require 'twitter_friendly/rest/extension/timelines'

module TwitterFriendly
  module REST
    module API
      include TwitterFriendly::REST::Utils
      include TwitterFriendly::REST::Collector
      include TwitterFriendly::REST::Parallel
      include TwitterFriendly::REST::FriendsAndFollowers
      include TwitterFriendly::REST::Users
      include TwitterFriendly::REST::Timelines
      include TwitterFriendly::REST::Search
      include TwitterFriendly::REST::Favorites
      include TwitterFriendly::REST::Lists
      include TwitterFriendly::REST::Tweets

      include TwitterFriendly::REST::Extension::Clusters
      include TwitterFriendly::REST::Extension::Timelines

      extend TwitterFriendly::REST::Users::CachingUsers
      caching_users

      extend TwitterFriendly::Caching
      caching_tweets_with_max_id :home_timeline, :user_timeline, :mentions_timeline, :favorites, :search
      caching_resources_with_cursor :friend_ids, :follower_ids, :memberships, :list_members
    end
  end
end
