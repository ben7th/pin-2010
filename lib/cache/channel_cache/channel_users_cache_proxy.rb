class ChannelUsersCacheProxy < RedisBaseProxy
  def initialize(channel)
    @channel = channel
    @key = "channel_#{@channel.id}_user_ids"
  end

  def xxxs_ids_db
    @channel.contact_users.map{|user|user.id}
  end
end
