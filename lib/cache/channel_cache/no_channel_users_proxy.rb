class NoChannelUsersProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_no_channel_user_ids"
  end

  def xxxs_ids_db
    @user.no_channel_contact_users_db.map {|user|user.id}
  end

  def add_contact(contact)
    add_to_cache(User.find_by_email(contact.email).id)
  end

  def remove_contact(contact)
    remove_from_cache(User.find_by_email(contact.email).id)
  end
  
end
