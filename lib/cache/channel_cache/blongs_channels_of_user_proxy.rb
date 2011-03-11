class BlongsChannelsOfUserProxy
  def initialize(user,channel_owner)
    @user = user
    @channel_owner = channel_owner
    @user_channels_of_user_key = "user_#{@user.id}_channel_of_user_#{channel_owner.id}_ids"
    @rmq_ucofk = RedisVectorArrayCache.new(@user_channels_of_user_key)
  end

  #  user1.belongs_to_channels_of_user(user2)
  #  KEY = user_:uid1_channel_of_user_:uid2_ids
  #  先读 KEY缓存 获取ids数组再获得 channels
  #  如果 KEY缓存 为空 则通过数据库查询获得，并建立 KEY缓存
  def belongs_channels_of_user
    if !@rmq_ucofk.exists
      reload_redis
    end
    channel_ids = @rmq_ucofk.all
    channel_ids.map{|id|Channel.find_by_id(id)}
  end

  def reload_redis
    channel_ids = @user.channels_of(@channel_owner).map {|channel| channel.id }
    @rmq_ucofk.set(channel_ids)
  end
end
