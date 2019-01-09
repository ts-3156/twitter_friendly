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

    # @param method [Symbol]
    # @param user [Integer, String, nil]
    #
    # @option options [Array] :args
    # @option options [Integer] :count
    # @option options [Integer] :cursor
    # @option options [String] :hash
    # @option options [String] :super_operation
    # @option options [String] :super_super_operation
    # @option options [Bool] :recursive
    def fetch(method, user, options = {}, &block)
      key = CacheKey.gen(method, user, options.except(:args))

      block_result = nil
      blk =
          Proc.new do
            block_result = yield
            encode(block_result, options[:args])
          end

      fetch_result = @client.fetch(key, &blk)

      block_result ? block_result : decode(fetch_result, options[:args])
    end

    private

    def encode(obj, args)
      Serializer.encode(obj, args: args)
    end

    def decode(str, args)
      Serializer.decode(str, args: args)
    end
  end
end
