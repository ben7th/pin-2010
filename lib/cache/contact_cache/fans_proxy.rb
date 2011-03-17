class FansProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @email = user.email
    @mindpin_email = EmailActor.get_mindpin_email(user)

    @key = "fans_contacts_vector_#{@email}"
  end

  def xxxs_ids_db
    Contact.find(
      :all,
      :conditions=>"email = '#{@email}' or email = '#{@mindpin_email}' ",
      :order=>"id desc").map{|c| c.id} # 读数据库
  end

end
