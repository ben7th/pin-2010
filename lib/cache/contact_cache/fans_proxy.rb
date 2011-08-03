class FansProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_fans_vector"
  end

  def xxxs_ids_db
    @user.fans_db.map{|user|user.id}
  end

  def self.change_cache_when_create(channel_user)
    user = channel_user.user
    channel = channel_user.channel

    channels = channel.creator.channels_of_user(user)
    return if (channels-[channel]).count != 0

    FansProxy.new(user).add_to_cache(channel.creator.id)
  end

  def self.change_cache_when_destroy(channel_user)
    user = channel_user.user
    channel = channel_user.channel

    channels = channel.creator.channels_of_user(user)
    return if (channels-[channel]).count != 0

    FansProxy.new(user).remove_from_cache(channel.creator.id)
  end

  def self.rules
    {
      :class=>ChannelUser,
      :after_create=>Proc.new{|channel_user|
        FansProxy.change_cache_when_create(channel_user)
      },
      :after_destroy=>Proc.new{|channel_user|
        FansProxy.change_cache_when_destroy(channel_user)
      }
    }
  end

  def self.funcs
    {
      :class=>User,
      :fans=>Proc.new{|user|
        FansProxy.new(user).get_models(User)
      },
      :hotfans=>Proc.new{|user|
        user.fans
      }
    }
  end
end
