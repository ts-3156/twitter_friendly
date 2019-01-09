module TwitterFriendly
  module Utils
    def uid_or_screen_name?(object)
      raise NotImplementedError.new("You must implement ##{__method__}.")
      object.kind_of?(String) || object.kind_of?(Integer)
    end

    def authenticating_user?(target)
      raise NotImplementedError.new("You must implement ##{__method__}.")
      user.id.to_i == user(target).id.to_i
    end

    def authorized_user?(target)
      raise NotImplementedError.new("You must implement ##{__method__}.")
      target_user = user(target)
      !target_user.protected? || friendship?(user.id.to_i, target_user.id.to_i)
    end
  end
end