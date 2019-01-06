module TwitterFriendly
  ::RSpec.describe Serializer do
    describe '.encode' do
      it do
        expect(Serializer.encode(a: 1)).to eq(JSON.dump(a: 1))
      end
    end

    describe '.decode' do
      it do
        expect(Serializer.decode(JSON.dump(a: 1))).to eq(JSON.parse(JSON.dump(a: 1), symbolize_names: true))
      end
    end
  end
end