class ChannelCacheProxy

  # user是被执行 添加 移除操作的人
  def initialize(user,channel)
    @user_id,@channel_id = user.id,channel.id
    @user, @channel = user, channel
    @user_channels_key = "user_#{@user_id}_channel_ids"
    @channel_users_key = "channel_#{@channel_id}_user_ids"
    @user_channels_of_user_key = "user_#{@user_id}_channel_of_user_#{@channel.creator.id}_ids"
    @no_channel_users_key = "user_#{@channel.creator.id}_no_channel_user_ids"

    @rmq_uck = RedisVectorArrayCache.new(@user_channels_key)
    @rmq_cuk = RedisVectorArrayCache.new(@channel_users_key)
    @rmq_ucofk = RedisVectorArrayCache.new(@user_channels_of_user_key)
    @rmq_dcuk = RedisVectorArrayCache.new(@no_channel_users_key)

  end

  def add_channel_id_to_user_channels
    if !@rmq_uck.exists
      return UserChannelsCacheProxy.new(@user).reload_redis
    end
    @rmq_uck.push(@channel_id)
  end

  def remove_channel_id_from_user_channels
    if !@rmq_uck.exists
      return UserChannelsCacheProxy.new(@user).reload_redis
    end
    @rmq_uck.remove(@channel_id)
  end

  def add_user_id_to_channel_user_ids
    if !@rmq_cuk.exists
      return ChannelUsersCacheProxy.new(@channel).reload_redis
    end
    @rmq_cuk.push(@user_id)
  end

  def remove_user_id_from_channel_user_ids
    if !@rmq_cuk.exists
      return ChannelUsersCacheProxy.new(@channel).reload_redis
    end
    @rmq_cuk.remove(@user_id)
  end

  def add_channel_id_to_of_user_channel_ids
    if !@rmq_ucofk.exists
      return BlongsChannelsOfUserProxy.new(@user,@channel.creator).reload_redis
    end
    @rmq_ucofk.push(@channel_id)
  end

  def remove_channel_id_from_of_user_channel_ids
    if !@rmq_ucofk.exists
      return BlongsChannelsOfUserProxy.new(@user,@channel.creator).reload_redis
    end
    @rmq_ucofk.remove(@channel_id)
  end

  def add_user_id_to_creator_no_channel
    if !@rmq_dcuk.exists
      return NoChannelUsersProxy.new(@channel.creator).reload_redis
    end
    @rmq_dcuk.push(@user_id)
  end

  def remove_user_id_from_creator_no_channel
    if !@rmq_dcuk.exists
      return NoChannelUsersProxy.new(@channel.creator).reload_redis
    end
    @rmq_dcuk.remove(@user_id)
  end

  # 用户加入到channel之后做的操作
  def add
    add_channel_id_to_user_channels
    add_user_id_to_channel_user_ids
    add_channel_id_to_of_user_channel_ids
    if @channel.creator.no_channel_contact_users_by_redis.include?(@user)
      remove_user_id_from_creator_no_channel
    end
  end

  # 将用户从channel中移除之后的操作
  def remove
    remove_channel_id_from_user_channels
    remove_user_id_from_channel_user_ids
    remove_channel_id_from_of_user_channel_ids
    # 如果是channel的creator的联系人，检查是否还在这个人的某一个channel中，如不在放入默认channel
    channels_of_user = @channel.creator.channels_of(@user)
    if channels_of_user.blank? || channels_of_user == [@channel]
      add_user_id_to_creator_no_channel
    end
  end

end
