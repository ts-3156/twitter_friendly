module TwitterFriendly
  module REST
    ::RSpec.describe Users do
      let(:dummy_class) do
        Class.new do
          include Users

          def credentials_hash
            'credentials_hash'
          end
        end
      end

      let(:client) do
        dummy_class.new.tap do |i|
          i.instance_variable_set(:@twitter, Twitter::REST::Client.new)
          i.instance_variable_set(:@cache, TwitterFriendly::Cache.new)
        end
      end
      let(:internal_client) { client.instance_variable_get(:@twitter) }
      let(:id) { 58135830 }

      describe '#verify_credentials' do
        it do
          expect(internal_client).to receive(:verify_credentials).with(include_entities: false, skip_status: true, include_email: true)
          client.verify_credentials
        end
      end

      describe '#user?' do
        it do
          expect(internal_client).to receive(:user?).with(id)
          client.user?(id)
        end
      end

      describe '#user' do
        it do
          expect(internal_client).to receive(:user).with(id)
          client.user(id)
        end

        context 'Without params' do
          it do
            expect(internal_client).to receive(:user).with(no_args)
            client.user
          end
        end
      end

      describe '#users' do
        subject { client.users(ids) }
        let(:ids) { [id] }
        let(:return_value) { ids.map {|id| {id: id}} }
        it do
          expect(internal_client).to receive(:users).with(ids, {}).and_return(return_value)
          subject
        end

        context 'ids.length > 100' do
          subject { client.users(ids) }
          before { dummy_class.send(:include, Parallel) }

          let(:ids) { Array.new(101) {id} }
          it do
            ids.each_slice(Users::MAX_USERS_PER_REQUEST).each do |ids_array|
              expect(internal_client).to receive(:users).with(ids_array, {}).and_return(return_value)
            end
            subject
          end
        end
      end

      describe '#blocked_ids' do
        subject { client.blocked_ids }
        it do
          expect(internal_client).to receive(:blocked_ids).with(no_args)
          subject
        end
      end
    end
  end
end
