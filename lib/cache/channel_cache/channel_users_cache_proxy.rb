class ChannelUsersCacheProxy
  def initialize(channel)
    @channel = channel
    @channel_users_key = "channel_#{@channel.id}_user_ids"
    @rmq_cuk = RedisVectorArrayCache.new(@channel_users_key)
  end

  #  查询时：
  #  channel.users
  #  KEY = channel_:cid_users_ids
  #  先读 KEY缓存 获取ids数组再获得 users
  #  如果 KEY缓存 为空 则通过数据库查询获得，并建立 KEY缓存
  #只有channel
  def channel_users
    if !@rmq_cuk.exists
      reload_redis
    end
    user_ids = @rmq_cuk.all
    user_ids.map{|id|User.find_by_id(id)}
  end

  def reload_redis
    user_ids = @channel.contact_users.map{|user|user.id}
    @rmq_cuk.set(user_ids)
  end
end
