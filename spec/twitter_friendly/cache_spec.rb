require 'fileutils'

module TwitterFriendly
  ::RSpec.describe Cache do
    let(:instance) { Cache.new }
    let(:internal_client) { instance.instance_variable_get(:@client) }
    let(:method_name) { :anything }
    let(:id) { 58135830 }

    describe '#clear' do
      it do
        expect(internal_client).to receive(:clear)
        instance.clear
      end
    end

    describe '#cleanup' do
      it do
        expect(internal_client).to receive(:cleanup)
        instance.cleanup
      end
    end

    describe '#encode' do
      let(:obj) { Object.new }
      let(:options) { {something: true} }
      it do
        expect(Serializer).to receive(:encode).with(obj, options)
        instance.send(:encode, obj, options)
      end
    end

    describe '#decode' do
      let(:str) { 'str' }
      let(:options) { {something: true} }
      it do
        expect(Serializer).to receive(:decode).with(str, options)
        instance.send(:decode, str, options)
      end
    end

    describe '#initialize' do
      let(:cache_dir) { '.test/cache/dir' }
      before { FileUtils.rm_f(cache_dir) }
      it 'creates cache_dir' do
        Cache.new(cache_dir: cache_dir)
        expect(File.exists?(cache_dir)).to be_truthy
      end
    end

    describe '#fetch' do
      let(:key) { 'key' }
      let(:serialize_options) { {something: false, args: {anything: true}} }

      it 'calls internal fetch' do
        expect(internal_client).to receive(:fetch).with(key)
        instance.fetch(key, serialize_options) { 'result' }
      end

      context 'Key exists' do
        let(:fetch_result) { {a: 1}.to_json }
        before do
          internal_client.write(key, fetch_result)
        end

        it do
          expect(instance.fetch(key, serialize_options)).to eq({a: 1})
        end

        it "doesn't call #encode" do
          expect(instance).to_not receive(:encode)
          instance.fetch(key, serialize_options)
        end

        it 'calls #decode' do
          expect(instance).to receive(:decode).with(fetch_result, serialize_options).and_return(JSON.parse(fetch_result, symbolize_names: true))
          instance.fetch(key, serialize_options)
        end
      end

      context "Key doesn't exist" do
        let(:block_result) { {b: 2} }
        before { internal_client.clear }

        it do
          expect(instance.fetch(key, serialize_options) { block_result }).to eq({b: 2})
        end

        it 'calls #encode' do
          expect(instance).to receive(:encode).with(block_result, serialize_options)
          instance.fetch(key, serialize_options) { block_result }
        end

        it "doesn't call #decode" do
          expect(instance).to_not receive(:decode)
          instance.fetch(key, serialize_options) { block_result }
        end
      end
    end
  end
end
