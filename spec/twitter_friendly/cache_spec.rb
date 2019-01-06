module TwitterFriendly
  ::RSpec.describe Cache do
    let(:instance) { Cache.new }
    describe '#initialize' do
      it do
        expect(Cache.new.instance_variable_get(:@client)).to be_truthy
      end
    end
  end
end
