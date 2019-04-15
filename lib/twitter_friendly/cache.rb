require 'forwardable'
require 'fileutils'

module TwitterFriendly
  class Cache
    extend Forwardable
    def_delegators :@client, :clear, :cleanup

    def initialize(*args)
      options = {expires_in: 1.hour, race_condition_ttl: 5.minutes}.merge(args.extract_options!)

      path = options[:cache_dir] || File.join('cache')
      FileUtils.mkdir_p(path) unless File.exists?(path)
      @client = ::ActiveSupport::Cache::FileStore.new(path, options)
    end

    def fetch(key, args:, &block)
      block_result = nil
      yield_and_encode = Proc.new do
        block_result = yield
        encode(block_result, args: args)
      end

      # 目的のデータがキャッシュになかった場合、キャッシュにはシリアライズしたJSONを保存しつつ、
      # このメソッドの呼び出し元にはJSONにシリアライズする前の結果を返している。
      # こうしないと、不要なデコードをすることになってしまう。

      fetch_result = @client.fetch(key, &yield_and_encode)

      block_result || decode(fetch_result, args: args)
    end

    private

    def encode(obj, args:)
      Serializer.encode(obj, args: args)
    end

    def decode(str, args:)
      Serializer.decode(str, args: args)
    end
  end
end
