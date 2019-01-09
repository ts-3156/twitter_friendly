require 'forwardable'
require 'fileutils'

module TwitterFriendly
  class Cache
    extend Forwardable
    def_delegators :@client, :clear, :cleanup

    def initialize(*args)
      options = {expires_in: 1.hour, race_condition_ttl: 5.minutes}.merge(args.extract_options!)

      path = options[:cache_dir] || File.join('.twitter_friendly', 'cache')
      FileUtils.mkdir_p(path) unless File.exists?(path)
      @client = ::ActiveSupport::Cache::FileStore.new(path, options)
    end

    # @param key [String]
    #
    # @option serialize_options [Array] :args
    def fetch(key, serialize_options, &block)
      block_result = nil
      yield_and_encode =
          Proc.new do
            block_result = yield
            encode(block_result, serialize_options)
          end

      fetch_result = @client.fetch(key, &yield_and_encode)

      block_result || decode(fetch_result, serialize_options)
    end

    private

    # @option options [Array] :args
    def encode(obj, options)
      Serializer.encode(obj, options)
    end

    # @option options [Array] :args
    def decode(str, options)
      Serializer.decode(str, options)
    end
  end
end
