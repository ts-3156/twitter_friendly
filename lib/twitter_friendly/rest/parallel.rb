module TwitterFriendly
  module REST
    module Parallel
      def parallel(options = {}, &block)
        batch = Arguments.new
        yield(batch)

        in_threads = options.fetch(:in_threads, batch.size)

        ::Parallel.map_with_index(batch, in_threads: in_threads) do |args, i|
          {i: i, result: send(*args)} # Cached here
        end.sort_by { |q| q[:i] }.map { |q| q[:result] }
      end

      class Arguments < Array
        %i(
        users
        friend_ids
        follower_ids
        friends
        followers
      ).each do |name|
          define_method(name) do |*args|
            send(:<< , [name, *args])
          end
        end
      end
    end
  end
end