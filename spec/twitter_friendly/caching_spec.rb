module TwitterFriendly
  ::RSpec.describe CachingAndLogging do
    let(:name) { 'Shinohara' }
    let(:place) { 'Tokyo' }

    let(:dummy_class) do
      Class.new do
        def method_missing(method, *args, &block)
          "#{method} is called with #{args.inspect}"
        end

        def credentials_hash
          'credentials_hash'
        end

        extend Caching
      end
    end

    let(:cache) { TwitterFriendly::Cache.new }

    let(:client) do
      dummy_class.new.tap do |i|
        i.instance_variable_set(:@cache, cache)
      end
    end

    shared_examples 'boilerplate' do
      it do
        expect(CacheKey).to receive(:gen).with(method_name, [name, options], hash: 'credentials_hash').and_return(cache_key)
        expect(cache).to receive(:fetch).with(cache_key, args: [method_name, options])
        client.send(method_name, name, options.except(:count))
      end
    end

    describe '.caching_tweets_with_max_id' do
      let(:cache_key) { 'key' }
      let(:options) { {place: place, count: count} }

      before { dummy_class.send(:caching_tweets_with_max_id, method_name) }

      context 'method_name == :home_timeline' do
        let(:method_name) { :home_timeline }
        let(:count) { 200 }
        it_behaves_like 'boilerplate'
      end

      context 'method_name == :user_timeline' do
        let(:method_name) { :user_timeline }
        let(:count) { 200 }
        it_behaves_like 'boilerplate'
      end

      context 'method_name == :mentions_timeline' do
        let(:method_name) { :mentions_timeline }
        let(:count) { 200 }
        it_behaves_like 'boilerplate'
      end

      context 'method_name == :favorites' do
        let(:method_name) { :favorites }
        let(:count) { 100 }
        it_behaves_like 'boilerplate'
      end

      context 'method_name == :search' do
        let(:method_name) { :search }
        let(:count) { 100 }
        it_behaves_like 'boilerplate'
      end
    end

    describe '.caching_resources_with_cursor' do

    end
  end
end
