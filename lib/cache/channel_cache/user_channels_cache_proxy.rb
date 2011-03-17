class UserChannelsCacheProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_channel_ids"
  end

  def xxxs_ids_db
    @user.belongs_to_channels_db.map{|channel|channel.id}
  end

end