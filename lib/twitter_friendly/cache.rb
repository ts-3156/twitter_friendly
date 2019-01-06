require 'forwardable'
require 'fileutils'

module TwitterFriendly
  class Cache
    extend Forwardable
    def_delegators :@client, :clear, :cleanup

    def initialize(*args)
      options = args.extract_options!

      path = options[:cache_dir] || File.join('.twitter_friendly', 'cache')
      FileUtils.mkdir_p(path) unless File.exists?(path)
      @client = ::ActiveSupport::Cache::FileStore.new(path, expires_in: 1.hour, race_condition_ttl: 5.minutes)
    end

    def fetch(method, user, options = {}, &block)
      key = CacheKey.gen(method, user, options.except(:args))

      block_result = nil
      fetch_result =
          @client.fetch(key) do
            block_result = yield
            encode(block_result, args: options[:args])
          end

      block_result ? block_result : decode(fetch_result, args: options[:args])
    end

    private

    def encode(obj, options)
      Serializer.encode(obj, options)
    end

    def decode(str, options)
      Serializer.decode(str, options)
    end
  end
end
