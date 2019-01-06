module TwitterFriendly
  class Utils
    class << self
      def extract_options!(ary)
        ary.last.is_a?(::Hash) ? ary.pop : {}
      end
    end
  end
end