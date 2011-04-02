class NoChannelUsersProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_no_channel_user_ids"
  end

  def xxxs_ids_db
    @user.no_channel_contact_users_db.map {|user|user.id}
  end

  def add_contact(contact)
    add_to_cache(contact.follow_user_id)
  end

  def remove_contact(contact)
    remove_from_cache(contact.follow_user_id)
  end
  
end
