module TwitterFriendly
  ::RSpec.describe Logger do
    let(:instance) { Logger.new }

    describe '#debug' do
      it do
        expect(instance.debug('debug')).to be_truthy
      end
    end

    describe '#info' do
      it do
        expect(instance.info('info')).to be_truthy
      end
    end

    describe '#warn' do
      it do
        expect(instance.warn('warn')).to be_truthy
      end
    end

    describe '#level' do
      it do
        expect(instance.level).to eq(::Logger::DEBUG)
      end
    end
  end
end