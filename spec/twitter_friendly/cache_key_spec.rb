module TwitterFriendly
  ::RSpec.describe CacheKey do
    let(:klass) { CacheKey }
    let(:delim) { klass::DELIM }
    let(:method) { :anything }
    let(:id) { 58135830 }
    let(:options) { {something: true} }

    describe '.gen' do
      it do
        allow(klass).to receive(:method_identifier).with(method, id, options).and_return('MI')
        allow(klass).to receive(:options_identifier).with(method, options).and_return('OI')
        expect(klass.gen(method, id, options)).to eq("v1#{delim}#{method}#{delim}MI#{delim}OI")
      end
    end

    describe '.method_identifier' do
      shared_examples 'boilerplate' do
        it {expect(klass.send(:method_identifier, method, id, options)).to eq(result)}
      end

      context 'method == :search' do
        let(:method) { :search }
        let(:result) { "query#{delim}#{id}" }
        it_behaves_like 'boilerplate'
      end

      context 'method == :friendship?' do
        let(:id) { [123, 456] }
        let(:method) { :friendship? }
        let(:result) { "from#{delim}#{123}#{delim}to#{delim}#{456}" }
        it_behaves_like 'boilerplate'
      end

      context 'method == :list_members' do
        let(:method) { :list_members }
        let(:result) { "list_id#{delim}#{id}" }
        it_behaves_like 'boilerplate'
      end

      context 'user.nil? && options[:hash].present?' do
        let(:id) { nil }
        let(:options) { {hash: 'hash123'} }
        let(:result) { "token-hash#{delim}#{options[:hash]}" }
        it_behaves_like 'boilerplate'
      end

      context 'method == :anything && user.present?' do
        let(:result) { 'result' }
        before { allow(klass).to receive(:user_identifier).with(id).and_return(result) }
        it_behaves_like 'boilerplate'
      end
    end

    describe '.user_identifier' do
      shared_examples 'boilerplate' do
        it {expect(klass.send(:user_identifier, id)).to eq(result)}
      end

      context 'user is Integer' do
        let(:id) { 123 }
        let(:result) { "id#{delim}#{id}" }
        it_behaves_like 'boilerplate'
      end

      context 'user is String' do
        let(:id) { 'name123' }
        let(:result) { "screen_name#{delim}#{id}" }
        it_behaves_like 'boilerplate'
      end

      context 'user is empty Array' do
        let(:id) { [] }
        let(:result) { 'The_#users_is_called_with_an_empty_array' }
        it_behaves_like 'boilerplate'
      end

      context 'user is [Integer, ...]' do
        let(:id) { [123, 456] }
        let(:result) { "ids#{delim}#{id.size}-#{'hash123'}" }
        before { allow(klass).to receive(:hexdigest).and_return('hash123') }
        it_behaves_like 'boilerplate'
      end

      context 'user is [String, ...]' do
        let(:id) { %w(name123 name456) }
        let(:result) { "screen_names#{delim}#{id.size}-#{'hash123'}" }
        before { allow(klass).to receive(:hexdigest).and_return('hash123') }
        it_behaves_like 'boilerplate'
      end

      context 'user is Hash' do
        let(:id) { {id: 123} }
        it {expect {klass.send(:user_identifier, id)}.to raise_error(RuntimeError)}
      end
    end

    describe '.options_identifier' do
      it 'ignores hash, call_count, call_limit, super_operation and parallel' do
        %i(hash call_count call_limit super_operation parallel).each do |key|
          expect(klass.send(:options_identifier, :something, {key => 'anything'})).to eq(nil)
        end
      end

      it 'encodes Hash to String' do
        expect(klass.send(:options_identifier, :something, key: 'anything', key2: 'something')).to eq("options#{delim}key=anything&key2=something")
      end
    end

    describe 'hexdigest' do
      it do
        expect(klass.send(:hexdigest, %w(1 2))).to eq(Digest::MD5.hexdigest('1,2'))
      end
    end
  end
end
