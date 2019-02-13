module TwitterFriendly
  module REST
    ::RSpec.describe Collector do
      let(:dummy_class) do
        Class.new do
          include Collector
          include Base
          include Timelines
        end
      end

      let(:client) do
        dummy_class.new.tap{|i| i.instance_variable_set(:@twitter, Twitter::REST::Client.new) }
      end
      let(:internal_client) { client.instance_variable_get(:@twitter) }

    end
  end
end
