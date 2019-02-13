module TwitterFriendly
  module REST
    ::RSpec.describe Timelines do
      let(:dummy_class) do
        Class.new do
          include Collector
          include Base
          include Timelines
        end
      end

      let(:client) do
        dummy_class.new.tap{|i| i.instance_variable_set(:@twitter, Twitter::REST::Client.new) }
      end
      let(:internal_client) { client.instance_variable_get(:@twitter) }

      describe '#home_timeline' do
        subject { client.home_timeline }
        it do
          expect(internal_client).to receive(:home_timeline).with(count: 200, include_rts: true)
          subject
        end

        context 'count > 200' do
          it do
            expect(client).to receive(:fetch_tweets_with_max_id).with(:home_timeline, 200, nil, count: 201, include_rts: true)
            client.home_timeline(count: 201)
          end
        end
      end

      describe '#user_timeline' do
        subject { client.user_timeline(id) }
        let(:id) { 58135830 }
        it do
          expect(internal_client).to receive(:user_timeline).with(id, count: 200, include_rts: true)
          client.user_timeline(id)
        end

        context 'count > 200' do
          it do
            expect(client).to receive(:fetch_tweets_with_max_id).with(:user_timeline, 200, id, count: 201, include_rts: true)
            client.user_timeline(id, count: 201)
          end
        end
      end

      describe '#mentions_timeline' do
        it do
          expect(internal_client).to receive(:mentions_timeline).with(count: 200, include_rts: true)
          client.mentions_timeline
        end

        context 'count > 200' do
          it do
            expect(client).to receive(:fetch_tweets_with_max_id).with(:mentions_timeline, 200, nil, count: 201, include_rts: true)
            client.mentions_timeline(count: 201)
          end
        end
      end
    end
  end
end
