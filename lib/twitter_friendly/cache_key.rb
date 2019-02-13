require 'digest/md5'

module TwitterFriendly
  class CacheKey
    DELIM = '__'
    VERSION = '1'

    class << self
      def gen(method, user, options = {})
        [version,
         method,
         method_identifier(method, user, options),
         options_identifier(method, options)
        ].compact.join(DELIM)
      end

      private

      def version
        'v' + VERSION
      end

      def method_identifier(method, user, options)
          case
          when method == :search                    then "query#{DELIM}#{user}"
          when method == :friendship?               then "from#{DELIM}#{user[0]}#{DELIM}to#{DELIM}#{user[1]}"
          when method == :list_members              then "list_id#{DELIM}#{user}"
          when method == :collect_with_max_id       then method_identifier(extract_super_operation(options), user, options)
          when method == :collect_with_cursor       then method_identifier(extract_super_operation(options), user, options)
          when user.nil? && options[:hash].present? then "token-hash#{DELIM}#{options[:hash]}"
          else user_identifier(user)
          end
      end

      def user_identifier(user)
        case
        when user.kind_of?(Integer)                            then "id#{DELIM}#{user}"
        when user.kind_of?(String)                             then "screen_name#{DELIM}#{user}"
        when user.kind_of?(Array) && user.empty?               then 'The_#users_is_called_with_an_empty_array'
        when user.kind_of?(Array) && user[0].kind_of?(Integer) then "ids#{DELIM}#{user.size}-#{hexdigest(user)}"
        when user.kind_of?(Array) && user[0].kind_of?(String)  then "screen_names#{DELIM}#{user.size}-#{hexdigest(user)}"
        else raise "#{__method__}: No matches #{user.inspect}"
        end
      end

      def options_identifier(method, options)
        # TODO 内部的な値はすべてprefix _tf_ をつける
        opt = options.except(:hash, :call_count, :call_limit, :super_operation, :super_super_operation, :recursive, :parallel)
        opt[:in] = extract_super_operation(options) if %i(collect_with_max_id collect_with_cursor).include?(method)

        if opt.empty?
          nil
        else
          str = opt.map {|k, v| "#{k}_#{v}"}.join('_')
          "options#{DELIM}#{str}"
        end
      end

      def extract_super_operation(options)
        raise ArgumentError.new('You must specify :super_operation.') unless options[:super_operation]
        if options[:super_operation].is_a?(Array)
          options[:super_operation][0]
        else
          options[:super_operation]
        end
      end

      def hexdigest(ary)
        Digest::MD5.hexdigest(ary.join(','))
      end
    end
  end
end