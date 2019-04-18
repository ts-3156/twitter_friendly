module TwitterFriendly
  module REST
    module Search

      MAX_TWEETS_PER_REQUEST = 100

      def search(query, options = {})
        raise ArgumentError.new('You must specify a search query.') unless query.is_a?(String)
        options = {result_type: 'recent'}.merge(options)

        if options[:count] <= MAX_TWEETS_PER_REQUEST
          # max_id で次のツイートを取得するので、このメソッドでは statuses を返してよい。
          # 逆に、cursor で次のツイートを取得するメソッドでは、レスポンス全体を返す必要がある。
          @twitter.search(query, options)&.attrs&.fetch(:statuses)
        else
          fetch_tweets_with_max_id(__method__, MAX_TWEETS_PER_REQUEST, query, options)
        end
      end
    end
  end
end