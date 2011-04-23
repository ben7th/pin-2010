# 某个用户参与的频道的向量缓存
# 该缓存中存储的是 Channel Id

class UserChannelsCacheProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_channel_ids"
  end

  # 缓存初始化查询方法
  def xxxs_ids_db
    @user.belongs_to_channels_db.map{|channel|channel.id}
  end

  def self.rules
    {
      :class=>ChannelUser,
      :after_create=>Proc.new{|channel_user|
        user = channel_user.user
        channel = channel_user.channel
        next if channel.blank? || user.blank?
        UserChannelsCacheProxy.new(user).add_to_cache(channel.id)
      },
      :after_destroy=>Proc.new{|channel_user|
        user = channel_user.user
        channel = channel_user.channel
        next if channel.blank? || user.blank?
        UserChannelsCacheProxy.new(user).remove_from_cache(channel.id)
      }
    }
  end

  def self.funcs
    {
      :class=>User,
      :belongs_to_channels_count=>Proc.new{|user|
        UserChannelsCacheProxy.new(user).xxxs_ids.count
      },
      :belongs_to_channels=>Proc.new{|user|
        UserChannelsCacheProxy.new(user).get_models(Channel)
      }
    }
  end

end