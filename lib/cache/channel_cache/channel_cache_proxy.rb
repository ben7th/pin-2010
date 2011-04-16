class ChannelCacheProxy

  # user是被执行 添加 移除操作的人
  def initialize(user,channel)
    @user, @channel = user, channel

    @user_channels_cache = UserChannelsCacheProxy.new(user)
    @channel_users_cache = ChannelUsersCacheProxy.new(channel)
    @blongs_channels_of_user_cache = BlongsChannelsOfUserProxy.new(user,channel.creator)
  end

  def add_channel_id_to_user_channels
    @user_channels_cache.add_to_cache(@channel.id)
  end

  def remove_channel_id_from_user_channels
    @user_channels_cache.remove_from_cache(@channel.id)
  end

  def add_user_id_to_channel_user_ids
    @channel_users_cache.add_to_cache(@user.id)
  end

  def remove_user_id_from_channel_user_ids
    @channel_users_cache.remove_from_cache(@user.id)
  end

  def add_channel_id_to_of_user_channel_ids
    @blongs_channels_of_user_cache.add_to_cache(@channel.id)
  end

  def remove_channel_id_from_of_user_channel_ids
    @blongs_channels_of_user_cache.remove_from_cache(@channel.id)
  end

  # 用户加入到channel之后做的操作
  def add
    add_channel_id_to_user_channels
    add_user_id_to_channel_user_ids
    add_channel_id_to_of_user_channel_ids
  end

  # 将用户从channel中移除之后的操作
  def remove
    remove_channel_id_from_user_channels
    remove_user_id_from_channel_user_ids
    remove_channel_id_from_of_user_channel_ids
  end
  
  module UserMethods
    def belongs_to_channels_count
      UserChannelsCacheProxy.new(self).xxxs_ids.count
    end

    def belongs_to_channels
      UserChannelsCacheProxy.new(self).xxxs_ids.map{|id|Channel.find_by_id(id)}.compact
    end

    def channels_of_user(user)
      BlongsChannelsOfUserProxy.new(user,self).xxxs_ids.map{|id|Channel.find_by_id(id)}.compact
    end
  end

  module ChannelMethods
    def include_users
      ChannelUsersCacheProxy.new(self).xxxs_ids.map{|id|User.find_by_id(id)}.compact
    end

    def include_users_and_creator
      include_users + [self.creator]
    end

    def main_users
      include_users_and_creator
    end

    def is_include_users_or_creator?(user)
      include_users_and_creator.include?(user)
    end
  end

  module ChannelUserMethods
    def self.included(base)
      base.after_save :add_channel_users_cache
      base.after_destroy :remove_channel_users_cache
    end

    def remove_channel_users_cache
      return true if self.channel.blank? || self.user.blank?
      ChannelCacheProxy.new(self.user,self.channel).remove
      return true
    end

    def add_channel_users_cache
      return true if self.channel.blank? || self.user.blank?
      ChannelCacheProxy.new(self.user,self.channel).add
      return true
    end
  end

end
