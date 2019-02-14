module TwitterFriendly
  module REST
    ::RSpec.describe Collector do
      let(:dummy_class) do
        Class.new do
          def hello(options = {})
            "hello #{options}"
          end

          include Collector
        end
      end

      let(:client) do
        dummy_class.new.tap{|i| i.instance_variable_set(:@twitter, Twitter::REST::Client.new) }
      end
      let(:internal_client) { client.instance_variable_get(:@twitter) }

      describe '#fetch_tweets_with_max_id' do
        let(:method_name) { :hello }
        it do
          expect(client).to receive(:hello).with(any_args)
          client.fetch_tweets_with_max_id(method_name, 100)
        end
      end

      describe '#fetch_resources_with_cursor' do
        let(:method_name) { :hello }
        it do
          expect(client).to receive(:hello).with(any_args)
          client.fetch_resources_with_cursor(method_name)
        end
      end

      describe '#collect_with_max_id' do

      end

      describe '#collect_with_cursor' do

      end
    end
  end
end
