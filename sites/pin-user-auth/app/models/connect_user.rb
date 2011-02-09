class ConnectUser < ActiveRecord::Base
  belongs_to :user

  SINA_CONNECT_TYPE = "sina"
  RENREN_CONNECT_TYPE = "renren"

  # 设置从新浪微博账号登录的用户
  def self.set_sina_connect_user(access_token)
    xml = access_token.get("/account/verify_credentials.xml").body
    doc = Nokogiri::XML(xml)
    connect_id = doc.at_css("id").content
    user_name = doc.at_css("name").content
    logo = doc.at_css("profile_image_url").content
    self.set_connect_user(SINA_CONNECT_TYPE,connect_id,user_name)
  end

  # 设置从人人网登录的用户
  def self.set_renren_connect_user(user_info_xml)
    doc = Nokogiri::XML(user_info_xml)
    connect_id = doc.at_css("uid").content
    user_name = doc.at_css("name").content
    logo = doc.at_css("tinyurl").content
    self.set_connect_user(RENREN_CONNECT_TYPE,connect_id,user_name)
  end

  def self.set_connect_user(type,connect_id,user_name)
    connect_user = ConnectUser.find_by_connect_type_and_connect_id(type,connect_id)
    if connect_user
      return connect_user.user
    end
    user = User.new(:name=>user_name)
    user.save(false)
    ConnectUser.create(:user_id=>user.id,:connect_type=>type,:connect_id=>connect_id)
    user.email = EmailActor.get_mindpin_email(user)
    user.save(false)
    return user
  end

  def rebind(rebind_user)
    old_user_id = self.user_id
    self.update_attributes(:old_user_id=>old_user_id,:user_id=>rebind_user.id)
  end
end
