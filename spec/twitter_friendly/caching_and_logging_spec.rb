module TwitterFriendly
  ::RSpec.describe CachingAndLogging do
    let(:method_name) { :greeting }
    let(:name) { 'Shinohara' }
    let(:place) { 'Tokyo' }

    let(:dummy_class) do
      Class.new do
        def greeting(name, options = {})
          "I'm #{name}. I live in #{place}."
        end

        def credentials_hash
          'credentials_hash'
        end

        extend CachingAndLogging
        caching :greeting
      end
    end

    let(:cache) { TwitterFriendly::Cache.new }

    let(:client) do
      dummy_class.new.tap do |i|
        i.instance_variable_set(:@cache, cache)
      end
    end

    describe '.caching' do
      let(:cache_key) { 'key' }
      it do
        expect(CacheKey).to receive(:gen).with(method_name, [name, {place: place}], hash: 'credentials_hash').and_return(cache_key)
        expect(cache).to receive(:fetch).with(cache_key, args: [method_name, {place: place}])
        client.send(method_name, name, place: place)
      end
    end
  end
end
