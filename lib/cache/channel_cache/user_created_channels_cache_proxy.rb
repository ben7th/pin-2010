class UserCreatedChannelsCacheProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_created_channel_ids"
  end

  # 缓存初始化查询方法
  def xxxs_ids_db
    @user.channels_db.map{|channel|channel.id}
  end

  def self.rules
    {
      :class=>Channel,
      :after_create=>Proc.new{|channel|
        creator = channel.creator
        UserCreatedChannelsCacheProxy.new(creator).add_to_cache(channel.id)
      },
      :after_destroy=>Proc.new{|channel|
        creator = channel.creator
        UserCreatedChannelsCacheProxy.new(creator).remove_from_cache(channel.id)
      }
    }
  end

  def self.funcs
    {
      :class=>User,
      :channels=>Proc.new{|user|
        UserCreatedChannelsCacheProxy.new(user).get_models(Channel)
      }
    }
  end

end