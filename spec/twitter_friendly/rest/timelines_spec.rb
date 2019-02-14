module TwitterFriendly
  module REST
    ::RSpec.describe Timelines do
      let(:dummy_class) do
        Class.new do
          include Collector
          include Timelines
        end
      end

      let(:client) do
        dummy_class.new.tap{|i| i.instance_variable_set(:@twitter, Twitter::REST::Client.new) }
      end
      let(:internal_client) { client.instance_variable_get(:@twitter) }

      describe '#home_timeline' do
        context 'count <= 200' do
          it do
            expect(internal_client).to receive(:home_timeline).with(count: 200, include_rts: true)
            client.home_timeline
          end
        end

        context 'count > 200' do
          it do
            expect(client).to receive(:fetch_tweets_with_max_id).with(:home_timeline, 200, count: 201, include_rts: true)
            client.home_timeline(count: 201)
          end
        end
      end

      describe '#user_timeline' do
        let(:id) { 58135830 }

        context 'count <= 200' do
          it do
            expect(internal_client).to receive(:user_timeline).with(id, count: 200, include_rts: true)
            client.user_timeline(id)
          end

          context 'Without params' do
            it do
              expect(internal_client).to receive(:user_timeline).with(count: 200, include_rts: true)
              client.user_timeline
            end
          end
        end

        context 'count > 200' do
          it do
            expect(client).to receive(:fetch_tweets_with_max_id).with(:user_timeline, 200, id, count: 201, include_rts: true)
            client.user_timeline(id, count: 201)
          end

          context 'Without params' do
            it do
              expect(client).to receive(:fetch_tweets_with_max_id).with(:user_timeline, 200, count: 201, include_rts: true)
              client.user_timeline(count: 201)
            end
          end
        end
      end

      describe '#mentions_timeline' do
        context 'count <= 200' do
          it do
            expect(internal_client).to receive(:mentions_timeline).with(count: 200, include_rts: true)
            client.mentions_timeline
          end
        end

        context 'count > 200' do
          it do
            expect(client).to receive(:fetch_tweets_with_max_id).with(:mentions_timeline, 200, count: 201, include_rts: true)
            client.mentions_timeline(count: 201)
          end
        end
      end
    end
  end
end
