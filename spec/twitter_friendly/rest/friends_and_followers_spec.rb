module TwitterFriendly
  module REST
    ::RSpec.describe FriendsAndFollowers do
      let(:dummy_class) do
        Class.new do
          include Collector
          include FriendsAndFollowers

          def user(*args)
          end
        end
      end

      let(:client) do
        dummy_class.new.tap{|i| i.instance_variable_set(:@twitter, Twitter::REST::Client.new) }
      end
      let(:internal_client) { client.instance_variable_get(:@twitter) }
      let(:id) { 58135830 }
      let(:to_id) { 22356250 }

      describe '#friendship?' do
        it do
          expect(internal_client).to receive(:friendship?).with(id, to_id, {})
          client.friendship?(id, to_id)
        end
      end

      describe '#friend_ids' do
        let(:options) { {count: 5000} }

        context 'With cursor' do
          before { options.merge!(cursor: -1) }

          it do
            expect(internal_client).to receive(:friend_ids).with(id, options)
            client.friend_ids(id)
          end

          context 'Without params' do
            it do
              expect(internal_client).to receive(:friend_ids).with(options)
              client.friend_ids
            end
          end
        end

        context 'Without cursor' do
          it do
            expect(client).to receive(:fetch_resources_with_cursor).with(:friend_ids, 5000, id, options)
            client.friend_ids(id)
          end

          context 'Without params' do
            it do
              expect(client).to receive(:fetch_resources_with_cursor).with(:friend_ids, 5000, options)
              client.friend_ids
            end
          end
        end
      end

      describe '#follower_ids' do
        let(:options) { {count: 5000} }

        context 'With cursor' do
          before { options.merge!(cursor: -1) }

          it do
            expect(internal_client).to receive(:follower_ids).with(id, options)
            client.follower_ids(id)
          end

          context 'Without params' do
            it do
              expect(internal_client).to receive(:follower_ids).with(options)
              client.follower_ids
            end
          end
        end

        context 'Without cursor' do
          it do
            expect(client).to receive(:fetch_resources_with_cursor).with(:follower_ids, 5000, id, options)
            client.follower_ids(id)
          end

          context 'Without params' do
            it do
              expect(client).to receive(:fetch_resources_with_cursor).with(:follower_ids, 5000, options)
              client.follower_ids
            end
          end
        end
      end

      describe '#friends' do
        let(:id) { 58135830 }
        let(:ids) { [1, 2, 3] }

        before { dummy_class.send(:include, Users) }
        it do
          expect(client).to receive(:friend_ids).with(id).and_return(ids)
          expect(client).to receive(:users).with(ids)
          client.friends(id)
        end
      end

      describe '#followers' do
        let(:id) { 58135830 }
        let(:ids) { [1, 2, 3] }
        before { dummy_class.send(:include, Users) }
        it do
          expect(client).to receive(:follower_ids).with(id).and_return(ids)
          expect(client).to receive(:users).with(ids)
          client.followers(id)
        end
      end

      describe '#friend_ids_and_follower_ids' do
        let(:id) { 58135830 }
        let(:friend_ids) { [1, 2, 3] }
        let(:follower_ids) { [4, 5, 6] }
        before { dummy_class.send(:include, Parallel) }
        it do
          expect(client).to receive(:friend_ids).with(id).and_return(friend_ids)
          expect(client).to receive(:follower_ids).with(id).and_return(follower_ids)
          expect(client.friend_ids_and_follower_ids(id)).to match_array([friend_ids, follower_ids])
        end
      end

      describe '#friends_and_followers' do
        let(:id) { 58135830 }
        let(:friend_ids) { [1, 2, 3] }
        let(:follower_ids) { [3, 4, 5] }
        let(:users) { (1..5).map{|n| {id: n} } }
        let(:friends) { friend_ids.map{|n| {id: n} } }
        let(:followers) { follower_ids.map{|n| {id: n} } }
        before { dummy_class.send(:include, Users) }
        it do
          expect(client).to receive(:friend_ids_and_follower_ids).with(id).and_return([friend_ids, follower_ids])
          expect(client).to receive(:users).with((friend_ids + follower_ids).uniq).and_return(users)
          expect(client.friends_and_followers(id)).to match_array([friends, followers])
        end
      end
    end
  end
end
