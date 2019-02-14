module TwitterFriendly
  ::RSpec.describe CacheKey do
    let(:delim) { described_class::DELIM }
    let(:method) { :anything }
    let(:id) { 58135830 }
    let(:options) { {something: true} }
    let(:cache_options) { {hash: :anything} }

    describe '.gen' do
      let(:args) { [id, options] }
      subject { described_class.gen(method, args, cache_options) }
      it do
        expect(described_class).to receive(:method_identifier).with(method, id, options, cache_options).and_return('MI')
        expect(described_class).to receive(:options_identifier).with(method, options, cache_options).and_return('OI')
        is_expected.to eq("v1#{delim}#{method}#{delim}MI#{delim}OI")
      end

      context 'method == :friendship?' do
        let(:to_id) { 'anything' }
        let(:args) { [id, to_id, options] }
        let(:method) { :friendship? }
        it do
          expect(described_class).to receive(:method_identifier).with(method, [id, to_id], options, cache_options)
          subject
        end
      end
    end

    describe '.method_identifier' do
      subject { described_class.send(:method_identifier, method, id, options, cache_options) }

      context 'method.nil? == true' do
        let(:method) { nil }
        it { expect {subject}.to raise_error(ArgumentError) }
      end

      context 'method == :search' do
        let(:method) { :search }
        let(:result) { "query#{delim}#{id}" }
        it { is_expected.to eq(result) }
      end

      context 'method == :friendship?' do
        let(:id) { [123, 456] }
        let(:method) { :friendship? }
        let(:result) { "from#{delim}#{123}#{delim}to#{delim}#{456}" }
        it { is_expected.to eq(result) }
      end

      context 'method == :list_members' do
        let(:method) { :list_members }
        let(:result) { "list_id#{delim}#{id}" }
        it { is_expected.to eq(result) }
      end

      context 'method == :collect_with_max_id && cache_options[:super_operation] == :anything' do
        let(:method) { :collect_with_max_id }
        let(:cache_options) { {super_operation: :anything} }
        it do
          expect(described_class).to receive(:super_operation_identifier).with(:anything, id, options, cache_options)
          subject
        end
      end

      context 'method == :collect_with_cursor && cache_options[:super_operation] == :anything' do
        let(:method) { :collect_with_cursor }
        let(:cache_options) { {super_operation: :anything} }
        it do
          expect(described_class).to receive(:super_operation_identifier).with(:anything, id, options, cache_options)
          subject
        end
      end

      context 'user.nil? && options[:hash].present?' do
        let(:id) { nil }
        let(:options) { {hash: 'hash123'} }
        let(:result) { "token-hash#{delim}#{options[:hash]}" }
        it { is_expected.to eq(result) }
      end

      context 'method == :anything && user.present?' do
        let(:result) { 'result' }
        it do
          expect(described_class).to receive(:user_identifier).with(id).and_return(result)
          is_expected.to eq(result)
        end
      end
    end

    describe '.user_identifier' do
      subject { described_class.send(:user_identifier, id) }

      context 'user is Integer' do
        let(:id) { 123 }
        let(:result) { "id#{delim}#{id}" }
        it { is_expected.to eq(result) }
      end

      context 'user is String' do
        let(:id) { 'name123' }
        let(:result) { "screen_name#{delim}#{id}" }
        it { is_expected.to eq(result) }
      end

      context 'user is empty Array' do
        let(:id) { [] }
        let(:result) { 'The_#users_is_called_with_an_empty_array' }
        it { is_expected.to eq(result) }
      end

      context 'user is [Integer, ...]' do
        let(:id) { [123, 456] }
        let(:result) { "ids#{delim}#{id.size}-#{'hash123'}" }
        before { allow(described_class).to receive(:hexdigest).and_return('hash123') }
        it { is_expected.to eq(result) }
      end

      context 'user is [String, ...]' do
        let(:id) { %w(name123 name456) }
        let(:result) { "screen_names#{delim}#{id.size}-#{'hash123'}" }
        before { allow(described_class).to receive(:hexdigest).and_return('hash123') }
        it { is_expected.to eq(result) }
      end

      context 'user is Hash' do
        let(:id) { {id: 123} }
        it {expect {described_class.send(:user_identifier, id)}.to raise_error(RuntimeError)}
      end
    end

    describe '.options_identifier' do
      it 'ignores hash, call_count, call_limit, super_operation and parallel' do
        %i(hash call_count call_limit super_operation parallel).each do |key|
          expect(described_class.send(:options_identifier, method, {key => 'anything'}, cache_options)).to eq(nil)
        end
      end

      it 'encodes Hash to String' do
        expect(described_class.send(:options_identifier, method, {key: 'anything', key2: 'something'}, cache_options)).to eq("options#{delim}key_anything_key2_something")
      end
    end

    describe 'hexdigest' do
      it do
        expect(described_class.send(:hexdigest, %w(1 2))).to eq(Digest::MD5.hexdigest('1,2'))
      end
    end
  end
end
