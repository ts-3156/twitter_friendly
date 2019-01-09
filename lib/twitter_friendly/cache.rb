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
      super_operation = options[:args].length >= 2 && options[:args][1][:super_operation]

      block_result = nil
      blk =
          Proc.new do
            block_result = yield
            encode(block_result, args: options[:args])
          end

      fetch_result =
        if super_operation
          @client.fetch(key, tf_super_operation: super_operation, &blk)
        else
          @client.fetch(key, &blk)
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
