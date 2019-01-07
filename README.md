# twitter_friendly

[![Gem Version](https://badge.fury.io/rb/twitter_friendly.png)](https://badge.fury.io/rb/twitter_friendly)
[![Build Status](https://travis-ci.org/ts-3156/twitter_friendly.svg?branch=master)](https://travis-ci.org/ts-3156/twitter_friendly)

A twitter-friendly Ruby interface to the Twitter API. This twitter_friendly gem provides multiple features.

- Auto pagination
- Auto caching
- Parallelly fetching

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'twitter_friendly'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install twitter_friendly
```

## Configuration

You can pass configuration options as a block to `TwitterFriendly::Client.new` just like the below.

```
client = TwitterFriendly::Client.new do |config|
  config.consumer_key        = "YOUR_CONSUMER_KEY"
  config.consumer_secret     = "YOUR_CONSUMER_SECRET"
  config.access_token        = "YOUR_ACCESS_TOKEN"
  config.access_token_secret = "YOUR_ACCESS_SECRET"
end
```

## Useful features

After configuring a `client`, you can do the following things.

Fetch all friends's user IDs (by screen name or user ID, or by implicit authenticated user)

```ruby
ids = client.follower_ids('gem')
ids.size
# => 1741
```

As using a cache, it's super fast from the second time.

```ruby
Benchmark.bm 20 do |r|
  r.report "Fetch follower_ids" do
    client.follower_ids('gem')
  end
  r.report "(Cached)" do
    client.follower_ids('gem')
  end
end

#                            user     system      total        real
# Fetch follower_ids     0.010330   0.003607   0.013937 (  0.981068)
# (Cached)               0.000865   0.000153   0.001018 (  0.001019) <- Roughly 900 times faster!
```

You don't need to write a boilerplate code as having auto pagination feature.

```ruby
users = client.follower_ids('a_user_has_many_friends')
users.size
# => 50000
```

If you don't use twitter_friendly gem, you must write the code like the below to fetch all follower's ids.

```ruby
def collect_with_max_id(collection=[], max_id=nil, &block)
  response = yield(max_id)
  collection += response
  response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
end

ids =
  collect_with_max_id do |max_id|
    options = {count: 200, include_rts: true}
    options[:max_id] = max_id unless max_id.nil?
    client.follower_ids('user_name', options)
  end
```

Additionally, twitter_friendly gem has a parallel execution feature.

```ruby
ids = [id1, id2, id3, ... , id1000]

Benchmark.bm 25 do |r|
  r.report "Fetch users in parallel" do
    client.users(ids)
  end

  client.cache.clear

  r.report "Fetch users in serial" do
    client.users(ids, parallel: false)
  end
end

#                                 user     system      total        real
# Fetch users in parallel     0.271966   0.057981   0.329947 (  2.675270) <- Super fast!
# Fetch users in serial       0.201375   0.044399   0.245774 (  8.068372)
```

## Usage examples

Fetch all friends's user IDs (by screen name or user ID, or by implicit authenticated user)

```ruby
client.friend_ids('gem')
client.friend_ids(213747670)
client.friend_ids
```

Fetch all followers's user IDs (by screen name or user ID, or by implicit authenticated user)

```ruby
client.follower_ids('gem')
client.follower_ids(213747670)
client.follower_ids
```

Fetch all friends with profile details (by screen name or user ID, or by implicit authenticated user)

```ruby
client.friends('gem')
client.friends(213747670)
client.friends
```

Fetch all followers with profile details (by screen name or user ID, or by implicit authenticated user)

```ruby
client.followers('gem')
client.followers(213747670)
client.followers
```


Fetch the timeline of Tweets (by screen name or user ID, or by implicit authenticated user)

```ruby
client.user_timeline('gem')
client.user_timeline(213747670)
client.user_timeline

result.size
# => 588

result.first.text
# => "Your tweet text..."

result.first.user.screen_name
# => "your_screen_name"
```

Fetch the timeline of Tweets from the authenticated user's home page

```ruby
client.home_timeline
```

Fetch the timeline of Tweets mentioning the authenticated user

```ruby
client.mentions_timeline
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ts-3156/twitter_friendly.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
