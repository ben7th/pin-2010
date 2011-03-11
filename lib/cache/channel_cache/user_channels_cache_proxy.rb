class UserChannelsCacheProxy
  def initialize(user)
    @user = user
    @user_channels_key = "user_#{@user.id}_channel_ids"
    @rmq_uck = RedisVectorArrayCache.new(@user_channels_key)
  end

  #  user.belongs_to_channels
  #  KEY = user_:uid_channel_ids
  #  先读 KEY缓存 获取ids数组再获得 channels
  #  如果 KEY缓存 为空 则通过数据库查询获得，并建立 KEY缓存
  # 只有user
  def belongs_channels
    if !@rmq_uck.exists
      reload_redis
    end
    channel_ids = @rmq_uck.all
    channel_ids.map{|id|Channel.find_by_id(id)}
  end

  def reload_redis
    channel_ids = @user.belongs_channels.map{|channel|channel.id}
    @rmq_uck.set(channel_ids)
  end
end