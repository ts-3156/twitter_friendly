module TwitterFriendly
  module REST
    ::RSpec.describe Search do
      let(:dummy_class) do
        Class.new do
          include Collector
          include Search
        end
      end

      let(:client) do
        dummy_class.new.tap{|i| i.instance_variable_set(:@twitter, Twitter::REST::Client.new) }
      end
      let(:internal_client) { client.instance_variable_get(:@twitter) }

      describe '#search' do
        let(:query) { 'egotter' }
        let(:receive_options) { {count: count, result_type: 'recent'} }

        context 'count <= 100' do
          let(:count) { 100 }
          it do
            expect(internal_client).to receive(:search).with(query, receive_options)
            client.search(query, receive_options)
          end
        end

        context 'count > 100' do
          let(:count) { 101 }
          it do
            expect(client).to receive(:fetch_tweets_with_max_id).with(:search, 100, query, receive_options)
            client.search(query, receive_options)
          end
        end
      end
    end
  end
end
