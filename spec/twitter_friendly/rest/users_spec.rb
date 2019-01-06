module TwitterFriendly
  module REST
    ::RSpec.describe Users do
      let(:dummy_class) { Class.new {include Users} }

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

      describe '#verify_credentials' do
        it do
          expect(internal_client).to receive(:verify_credentials).with(skip_status: true)
          instance.verify_credentials
        end
      end

      describe '#user?' do
        it do
          expect(internal_client).to receive(:user?).with(id)
          instance.user?(id)
        end
      end

      describe '#user' do
        it do
          expect(internal_client).to receive(:user).with(id)
          instance.user(id)
        end
      end

      describe '#users' do
        context 'ids.length <= 100' do
          let(:ids) { [id] }
          it do
            expect(internal_client).to receive(:users).with(*ids, {})
            instance.users(ids)
          end

          unless ENV['TRAVIS']
            context 'with real client' do
              let(:internal_client) { client.instance_variable_get(:@twitter) }
              it 'fetches real data' do
                expect(client.users(ids, cache: false)).to eq(internal_client.users(ids).map(&:to_hash))
              end
            end
          end
        end

        context 'ids.length > 100' do
          let(:ids) { Array.new(101) {id} }
          it do
            expect(instance).to receive(:_users).with(ids, {})
            instance.users(ids)
          end

          unless ENV['TRAVIS']
            context 'with real client' do
              let(:internal_client) { client.instance_variable_get(:@twitter) }
              let(:ids) { JSON.parse(fixture('friend_ids.json')).take(101) }
              it 'fetches real data' do
                expect(client.users(ids, cache: false).map{|u| u[:id] }).to eq(internal_client.users(ids).map(&:to_hash).map{|u| u[:id] })
              end
            end
          end
        end
      end

      describe '#_users' do
        let(:ids) { [id] }
        it do
          expect(internal_client).to receive(:users).with(ids, {super_operation: :users, parallel: true})
          instance.send(:_users, ids)
        end
      end

      describe '#blocked_ids' do
        it do
          expect(internal_client).to receive(:blocked_ids)
          instance.blocked_ids
        end
      end

    end
  end
end
