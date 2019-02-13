require 'digest/md5'

module TwitterFriendly
  module REST
    module Utils
      def credentials_hash
        Digest::MD5.hexdigest(access_token + access_token_secret + consumer_key + consumer_secret)
      end
    end
  end
end