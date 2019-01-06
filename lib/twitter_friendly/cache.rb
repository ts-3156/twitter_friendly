require 'forwardable'
require 'digest/md5'
require 'fileutils'

module TwitterFriendly
  class Cache
    extend Forwardable
    def_delegators :@client, :clear, :cleanup

    def initialize(*args)
      options = TwitterFriendly::Utils.extract_options!(args)

      path = options[:cache_dir] || File.join('.twitter_friendly', 'cache')
      FileUtils.mkdir_p(path) unless File.exists?(path)
      @client = ::ActiveSupport::Cache::FileStore.new(path, expires_in: 1.hour, race_condition_ttl: 5.minutes)
    end

    def fetch(method, user, options = {}, &block)
      key = normalize_key(method, user, options.except(:args))

      block_result = nil
      fetch_result =
          @client.fetch(key) do
            block_result = yield
            Serializer.encode(block_result, args: options[:args])
          end

      block_result ? block_result : Serializer.decode(fetch_result, args: options[:args])
    end

    private

    DELIM = ':'

    def normalize_key(method, user, options = {})
      identifier =
          case
          when method == :search                    then "query#{DELIM}#{user}"
          when method == :friendship?               then "from#{DELIM}#{user[0]}#{DELIM}to#{DELIM}#{user[1]}"
          when method == :list_members              then "list_id#{DELIM}#{user}"
          when user.nil? && options[:hash].present? then "token-hash#{DELIM}#{options[:hash]}"
          else user_identifier(user)
          end

      "#{method}#{DELIM}#{identifier}#{DELIM}#{options_identifier(options)}"
    end

    def user_identifier(user)
      case
      when user.kind_of?(Integer)                            then "id#{DELIM}#{user}"
      when user.kind_of?(String)                             then "screen_name#{DELIM}#{user}"
      when user.kind_of?(Array) && user.empty?               then 'The_#users_is_called_with_an_empty_array'
      when user.kind_of?(Array) && user[0].kind_of?(Integer) then "ids#{DELIM}#{user.size}-#{hexdigest(user.join(','))}"
      when user.kind_of?(Array) && user[0].kind_of?(String)  then "screen_names#{DELIM}#{user.size}-#{hexdigest(user.join(','))}"
      else raise "#{__method__}: No matches #{user.inspect}"
      end
    end

    def options_identifier(options)
      options = options.except(:hash, :call_count, :call_limit, :super_operation)
      str =
          if options.empty?
            'empty'
          else
            options.map { |k, v| "#{k}#{DELIM}#{v}" }.join(',')
          end
      "options#{DELIM}#{str}"
    end

    def hexdigest(str)
      Digest::MD5.hexdigest(str)
    end
  end
end
