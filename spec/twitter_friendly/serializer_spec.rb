module TwitterFriendly
  ::RSpec.describe Serializer do
    let(:coder) { JSON }

    def encode(*args)
      coder.dump(*args)
    end

    def decode(str)
      coder.parse(str, symbolize_names: true)
    end

    describe '.encode' do
      it do
        expect(Serializer.encode({a: 1}, args: [:anything])).to eq(encode(a: 1))
      end
    end

    describe '.decode' do
      it do
        str = JSON.dump(a: 1)
        expect(Serializer.decode(str, args: [:anything])).to eq(decode(str))
      end
    end

    describe '.coder' do
      it do
        expect(Serializer.coder.is_a?(Serializer::OjCoder)).to be_truthy
      end
    end

    describe '.coder=' do
      it do
        Serializer.coder = JSON
        expect(Serializer.coder.is_a?(Serializer::JsonCoder)).to be_truthy
      end
    end
  end
end