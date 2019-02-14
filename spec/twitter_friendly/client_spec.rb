module TwitterFriendly
  ::RSpec.describe Client do
    let(:client) do
      described_class.new(
          consumer_key: ENV['CK'],
          consumer_secret: ENV['CS'],
          access_token: ENV['AT'],
          access_token_secret: ENV['ATS']
      )
    end
    let(:cache) { client.cache }
    let(:internal_client) { client.internal_client }

    before { client.cache.clear }

    describe '#blocked_ids' do
      let(:blocked_ids) do
        klass =
            Class.new do
              def attrs
                {ids: [1, 2, 3]}
              end
            end
        klass.new
      end

      subject { client.blocked_ids }

      it do
        expect(internal_client).to receive(:blocked_ids).exactly(1).times.with(no_args).and_return(blocked_ids)
        is_expected.to match_array(blocked_ids.attrs[:ids])
        is_expected.to match_array(blocked_ids.attrs[:ids])
      end
    end

    describe '#friendships?' do
      let(:from) { 'ts_3156' }
      let(:to) { 'gwcak' }
      subject { client.friendship?(from, to) }

      it do
        expect(internal_client).to receive(:friendship?).exactly(1).times.with(from, to, {}).and_return(true)
        is_expected.to be_truthy
        is_expected.to be_truthy
      end

      context 'With another params' do
        before do
          ENV['SAVE_CACHE_KEY'] = 'true'
          allow(cache).to receive(:fetch).with(any_args)
        end

        it 'uses another cache key' do
          client.friendship?(from, to)
          key1 = $last_cache_key
          expect(client.friendship?(to, from)).to_not eq(key1)
        end
      end
    end

    describe '#user' do
      let(:id) { 'ts_3156' }
      subject { client.user(id) }

      let(:user) do
        klass =
            Class.new do
              def to_hash
                {id: 58135830, screen_name: 'ts_3156'}
              end
            end
        klass.new
      end

      it do
        expect(internal_client).to receive(:user).exactly(1).times.with(id).and_return(user)
        is_expected.to eq(user.to_hash)
        is_expected.to eq(user.to_hash)
      end

      context 'With another params' do
        before do
          ENV['SAVE_CACHE_KEY'] = 'true'
          allow(cache).to receive(:fetch).with(any_args)
        end

        it 'uses another cache key' do
          client.user(user.to_hash[:id])
          key1 = $last_cache_key
          expect(client.user(user.to_hash[:screen_name])).to_not eq(key1)
        end
      end
    end

    describe '#users' do
      let(:ids) { ['ts_3156', 'gwcak', 'mecab'] }
      subject { client.users(ids) }

      let(:users) do
        [
            {id: 58135830, screen_name: 'ts_3156'},
            {id: 22356250, screen_name: 'gwcak'},
            {id: 16298587, screen_name: 'mecab'}
        ]
      end

      it do
        expect(internal_client).to receive(:users).exactly(1).times.with(ids, {}).and_return(users)
        is_expected.to match_array(users)
        is_expected.to match_array(users)
      end

      context 'With another params' do
        before do
          ENV['SAVE_CACHE_KEY'] = 'true'
          allow(cache).to receive(:fetch).with(any_args)
        end

        it 'uses another cache key' do
          client.users(ids)
          key1 = $last_cache_key
          expect(client.users(ids.reverse)).to_not eq(key1)
        end
      end
    end

    describe '#friend_ids' do
      let(:id) { 'ts_3156' }
      subject { client.friend_ids(id) }
      let(:friend_ids) do
        klass =
            Class.new do
              def attrs
                {ids: [1, 2, 3], next_cursor: 0}
              end
            end
        klass.new
      end
      it do
        expect(internal_client).to receive(:friend_ids).exactly(1).times.with(id, count: 5000, cursor: -1).and_return(friend_ids)
        is_expected.to match_array(friend_ids.attrs[:ids])
        is_expected.to match_array(friend_ids.attrs[:ids])
      end
    end

    describe '#follower_ids' do
      let(:id) { 'ts_3156' }
      subject { client.follower_ids(id) }
      let(:follower_ids) do
        klass =
            Class.new do
              def attrs
                {ids: [1, 2, 3], next_cursor: 0}
              end
            end
        klass.new
      end
      it do
        expect(internal_client).to receive(:follower_ids).exactly(1).times.with(id, count: 5000, cursor: -1).and_return(follower_ids)
        is_expected.to match_array(follower_ids.attrs[:ids])
        is_expected.to match_array(follower_ids.attrs[:ids])
      end
    end

    describe '#home_timeline' do
      subject { client.home_timeline }
      it do
        expect(internal_client).to receive(:home_timeline).exactly(1).times.with(count: 200, include_rts: true)
        subject
        subject
      end

      context 'With another params' do
        before do
          ENV['SAVE_CACHE_KEY'] = 'true'
          allow(cache).to receive(:fetch).with(any_args)
        end

        it 'uses another cache key' do
          client.home_timeline(count: 200)
          key1 = $last_cache_key
          expect(client.home_timeline(count: 1)).to_not eq(key1)
        end
      end
    end

    describe '#user_timeline' do
      let(:id) { 'ts_3156' }
      subject { client.user_timeline(id) }
      it do
        expect(internal_client).to receive(:user_timeline).exactly(1).times.with(id, count: 200, include_rts: true)
        subject
        subject
      end

      context 'With another params' do
        before do
          ENV['SAVE_CACHE_KEY'] = 'true'
          allow(cache).to receive(:fetch).with(any_args)
        end

        it 'uses another cache key' do
          client.user_timeline(id, count: 200)
          key1 = $last_cache_key
          expect(client.user_timeline(id, count: 1)).to_not eq(key1)
        end
      end
    end

    describe '#mentions_timeline' do
      subject { client.mentions_timeline }
      it do
        expect(internal_client).to receive(:mentions_timeline).exactly(1).times.with(count: 200, include_rts: true)
        subject
        subject
      end

      context 'With another params' do
        before do
          ENV['SAVE_CACHE_KEY'] = 'true'
          allow(cache).to receive(:fetch).with(any_args)
        end

        it 'uses another cache key' do
          client.mentions_timeline(count: 200)
          key1 = $last_cache_key
          expect(client.mentions_timeline(count: 1)).to_not eq(key1)
        end
      end
    end

    describe '#search' do

    end

    describe '#favorites' do

    end
  end
end