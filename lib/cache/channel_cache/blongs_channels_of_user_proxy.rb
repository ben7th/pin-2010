class BlongsChannelsOfUserProxy < RedisBaseProxy
  def initialize(user,channel_owner)
    @user = user
    @channel_owner = channel_owner
    @key = "user_#{@user.id}_channel_of_user_#{channel_owner.id}_ids"
  end

  def xxxs_ids_db
    @channel_owner.channels_of_user_db(@user).map {|channel| channel.id }
  end
end
