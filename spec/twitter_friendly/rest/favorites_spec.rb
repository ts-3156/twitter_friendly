module TwitterFriendly
  module REST
    ::RSpec.describe Favorites do
      let(:dummy_class) do
        Class.new do
          include Collector
          include Favorites
        end
      end

      let(:client) do
        dummy_class.new.tap{|i| i.instance_variable_set(:@twitter, Twitter::REST::Client.new) }
      end
      let(:internal_client) { client.instance_variable_get(:@twitter) }

      describe '#favorites' do
        let(:id) { 'ts_3156' }
        let(:receive_options) { {count: count} }

        context 'count <= 100' do
          let(:count) { 100 }
          it do
            expect(internal_client).to receive(:favorites).with(id, receive_options)
            client.favorites(id, receive_options)
          end

          context 'Without params' do
            it do
              expect(internal_client).to receive(:favorites).with(receive_options)
              client.favorites(receive_options)
            end
          end
        end

        context 'count > 100' do
          let(:count) { 101 }
          it do
            expect(client).to receive(:fetch_tweets_with_max_id).with(:favorites, 100, id, receive_options)
            client.favorites(id, receive_options)
          end

          context 'Without params' do
            it do
              expect(client).to receive(:fetch_tweets_with_max_id).with(:favorites, 100, receive_options)
              client.favorites(receive_options)
            end
          end
        end
      end
    end
  end
end
