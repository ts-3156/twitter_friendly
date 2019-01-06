require 'digest/md5'

module TwitterFriendly
  class CacheKey
    DELIM = ':'

    class << self
      def gen(method, user, options = {})
        "#{method}#{DELIM}#{method_identifier(method, user, options)}#{DELIM}#{options_identifier(options)}"
      end

      private

      def method_identifier(method, user, options)
          case
          when method == :search                    then "query#{DELIM}#{user}"
          when method == :friendship?               then "from#{DELIM}#{user[0]}#{DELIM}to#{DELIM}#{user[1]}"
          when method == :list_members              then "list_id#{DELIM}#{user}"
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

      def options_identifier(options)
        options = options.except(:hash, :call_count, :call_limit, :super_operation)
        str =
            if options.empty?
              'empty'
            else
              options.map { |k, v| "#{k}=#{v}" }.join('&')
            end
        "options#{DELIM}#{str}"
      end

      def hexdigest(ary)
        Digest::MD5.hexdigest(ary.join(','))
      end
    end
  end
end