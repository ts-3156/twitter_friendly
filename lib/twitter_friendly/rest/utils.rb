require 'digest/md5'

module TwitterFriendly
  module REST
    module Utils
      def credentials_hash
        Digest::MD5.hexdigest(access_token + access_token_secret + consumer_key + consumer_secret)
      end

      def push_operations(options, operation)
        options[:super_operation] = [] unless options[:super_operation]
        options[:super_operation] = [options[:super_operation]] unless options[:super_operation].is_a?(Array)
        options[:super_operation].prepend operation
      end
    end
  end
end