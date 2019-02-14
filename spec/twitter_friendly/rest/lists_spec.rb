module TwitterFriendly
  module REST
    ::RSpec.describe Lists do
      let(:dummy_class) do
        Class.new do
          include Collector
          include Lists

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

      describe '#list' do
        let(:full_name) { '@kenta_drmn/new-list' }
        it do
          expect(internal_client).to receive(:list).with(full_name)
          client.list(full_name)
        end
      end

      describe '#memberships' do
        let(:receive_options) { {count: 1000} }
        let(:id) { 'ts_3156' }

        context 'With cursor' do
          before { receive_options.merge!(cursor: -1) }

          it do
            expect(internal_client).to receive(:memberships).with(id, receive_options)
            client.memberships(id)
          end

          context 'Without params' do
            it do
              expect(internal_client).to receive(:memberships).with(receive_options)
              client.memberships
            end
          end
        end

        context 'Without cursor' do
          it do
            expect(client).to receive(:fetch_resources_with_cursor).with(:memberships, id, receive_options)
            client.memberships(id)
          end

          context 'Without params' do
            it do
              expect(client).to receive(:fetch_resources_with_cursor).with(:memberships, receive_options)
              client.memberships
            end
          end
        end
      end


      describe '#list_members' do
        let(:receive_options) { {count: 5000, skip_status: 1} }
        let(:id) { 'ts_3156' }

        context 'With cursor' do
          before { receive_options.merge!(cursor: -1) }

          it do
            expect(internal_client).to receive(:list_members).with(id, receive_options)
            client.list_members(id)
          end

          context 'Without params' do
            it do
              expect(internal_client).to receive(:list_members).with(receive_options)
              client.list_members
            end
          end
        end

        context 'Without cursor' do
          it do
            expect(client).to receive(:fetch_resources_with_cursor).with(:list_members, id, receive_options)
            client.list_members(id)
          end

          context 'Without params' do
            it do
              expect(client).to receive(:fetch_resources_with_cursor).with(:list_members, receive_options)
              client.list_members
            end
          end
        end
      end
    end
  end
end
