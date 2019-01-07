require 'json'

module TwitterFriendly
  class Serializer
    class << self
      def encode(obj, options = {})
        Instrumenter.perform_encode(options) do
          (!!obj == obj) ? obj : coder.encode(obj)
        end
      end

      def decode(str, options = {})
        Instrumenter.perform_decode(options) do
          str.kind_of?(String) ? coder.decode(str) : str
        end
      end

      def coder
        @@coder ||= Coder.instance(JSON)
      end

      def coder=(coder)
        @@coder = Coder.instance(coder)
      end

      private

      module Instrumenter

        module_function

        def perform_encode(options, &block)
          payload = {operation: 'encode', args: options[:args]}
          ::ActiveSupport::Notifications.instrument('encode.twitter_friendly', payload) { yield(payload) }
        end

        def perform_decode(options, &block)
          payload = {operation: 'decode', args: options[:args]}
          ::ActiveSupport::Notifications.instrument('decode.twitter_friendly', payload) { yield(payload) }
        end
      end

      class Coder
        def initialize(coder)
          @coder = coder
        end

        def encode(obj)
          @coder.dump(obj)
        end

        def self.instance(coder)
          if coder == JSON
            JsonCoder.new(coder)
          elsif defined?(Oj) && coder == Oj
            OjCoder.new(coder)
          else
            raise "Invalid coder #{coder.inspect}"
          end
        end
      end

      class JsonCoder < Coder
        def decode(str)
          @coder.parse(str, symbolize_names: true)
        end
      end

      class OjCoder < Coder
        def decode(str)
          @coder.load(str, symbol_keys: true)
        end
      end
    end
  end
end
