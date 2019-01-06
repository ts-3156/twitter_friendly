module TwitterFriendly
  module REST
    ::RSpec.describe FriendsAndFollowers do
      let(:dummy_class) do
        Class.new do
          include Collector
          include FriendsAndFollowers
        end
      end

      let(:instance) do
        dummy_class.new.tap{|i| i.instance_variable_set(:@twitter, Twitter::REST::Client.new) }
      end
      let(:internal_client) { instance.instance_variable_get(:@twitter) }
      let(:id) { 58135830 }

      let(:client) do
        TwitterFriendly::Client.new(
            consumer_key: ENV['CK'],
            consumer_secret: ENV['CS'],
            access_token: ENV['AT'],
            access_token_secret: ENV['ATS']
        )
      end

      describe '#friendship?' do
        it do
          expect(internal_client).to receive(:friendship?).with(id, id, {})
          instance.friendship?(id, id)
        end
      end

      describe '#friend_ids' do
        context 'ids <= 5000' do
          let(:ids) {[id] }
          it do
            expect(instance).to receive(:collect_with_cursor)
            instance.friend_ids(ids)
          end
        end

        context 'ids > 5000' do
          let(:ids) { Array.new(5001) {id} }
          it do
            expect{instance.friend_ids(ids)}.to raise_error(ArgumentError)
          end
        end
      end
    end
  end
end
