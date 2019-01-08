#!/usr/bin/env ruby

require 'dotenv/load'
require 'twitter_friendly'

TwitterFriendly.cache.clear

client =
  TwitterFriendly::Client.new(
    consumer_key: ENV['CK'],
    consumer_secret: ENV['CS'],
    access_token: ENV['AT'],
    access_token_secret: ENV['ATS']
  )

def diff(ary1, ary2)
  [ary1 - ary2, ary2 - ary1]
end

def diff?(ary1, ary2)
  diff(ary1, ary2).flatten.any?
end

def users_diff(ary1, ary2)
  diff(ary1.map {|a| a[:id]}, ary2.map {|a| a[:id]})
end

def users_diff?(ary1, ary2)
  users_diff(ary1, ary2).flatten.any?
end

friend_ids = follower_ids = []

%i(friend_ids follower_ids).each do |method|
  ids = client.send(method)
  cached_ids = client.send(method)
  raw_ids = client.internal_client.send(method).attrs[:ids]

  puts method
  puts "  fetch #{ids.size}, cache #{cached_ids.size}, raw #{raw_ids.size}"
  puts "  ids is different from cached_ids diff=#{diff(ids, cached_ids).inspect}" if diff?(ids, cached_ids)
  puts "  cached_ids is different from raw_ids diff=#{diff(cached_ids, raw_ids).inspect}" if diff?(cached_ids, raw_ids)
  puts "  ids is different from raw_ids diff=#{diff(ids, raw_ids).inspect}" if diff?(ids, raw_ids)
  puts "  #{client.rate_limit.send(method)}"

  eval("#{method}=ids")
end

client.cache.clear

ids1, ids2 = client.friend_ids_and_follower_ids
cached_ids1, cached_ids2 = client.friend_ids_and_follower_ids

puts 'friend_ids_and_follower_ids'
puts "  fetch #{ids1.size}, cache #{cached_ids1.size}"
puts "  fetch #{ids2.size}, cache #{cached_ids2.size}"
puts "  ids1 is different from cached_ids1 diff=#{diff(ids1, cached_ids1)}" if diff?(ids1, cached_ids1)
puts "  ids2 is different from cached_ids2 diff=#{diff(ids2, cached_ids2)}" if diff?(ids2, cached_ids2)

client.cache.clear

friends = followers = []

%i(friends followers).each do |method|
  users = client.send(method)
  cached_users = client.send(method)
  # raw_users = client.internal_client.send(method).attrs[:users]

  puts method
  puts "  users #{users.size}, cached_users #{cached_users.size}"
  puts "  users is different from cached_users diff=#{users_diff(users, cached_users)}" if users_diff?(users, cached_users)
  # puts "  cached_users is different from raw_users" if cached_users != raw_users
  # puts "  users is different from raw_users" if users != raw_users
  puts "  #{client.rate_limit.send(method)}"

  eval("#{method}=users")
end

client.cache.clear

users1, users2 = client.friends_and_followers
cached_users1, cached_users2 = client.friends_and_followers

puts 'friends_and_followers'
puts "  fetch #{users1.size}, cache #{cached_users1.size}"
puts "  fetch #{users2.size}, cache #{cached_users2.size}"
puts "  users1 is different from cached_users1 diff=#{users_diff(users1, cached_users1)}" if users_diff?(users1, cached_users1)
puts "  users2 is different from cached_users2 diff=#{users_diff(users2, cached_users2)}" if users_diff?(users2, cached_users2)

client.cache.clear

puts friend_ids.zip(friends).all? {|id, user| id == user[:id] }
puts follower_ids.zip(followers).all? {|id, user| id == user[:id] }

puts 'ok'
