require 'digest/sha1'
module UserBaseModule
  # ------- consts define

  ADMIN_USER_EMAILS = case Rails.env
    when "development"
      ["ben7th@126.com"]
    when "test"
      ["ben7th@126.com"]
    when "production"
      [
        "ben7th@sina.com",
        "4820357@qq.com",
        "sophia.njtu@gmail.com"
      ]
    end

  AVATAR_PATH = "/:class/:attachment/:id/:style/:basename.:extension"
  AVATAR_URL  = "http://storage.aliyun.com/#{OssManager::CONFIG["bucket"]}/:class/:attachment/:id/:style/:basename.:extension"


  def self.included(base)
    base.set_readonly true
    base.set_table_name("users")

    base.has_attached_file :logo,
      :styles => {
        :large  => '200x200#',
        :medium => '96x96#',
        :normal => '48x48#',
        :tiny   => '32x32#',
        :mini   => '24x24#'
      },
      :storage => :oss,
      :path => AVATAR_PATH,
      :url  => AVATAR_URL,
      :default_url   => pin_url_for('ui',"/images/default_avatars/:style.png"),
      :default_style => :normal

    base.after_create :create_self_preference

    base.send(:include, InstanceMethods)
    base.send(:extend,  ClassMethods)

    base.send(:include, Preference::UserMethods)
  end

  module InstanceMethods
    def create_self_preference
      preference
      return true
    end

    # 尝试获取用户偏好数据，如果没有则创建
    def preference
      pref = Preference.find_by_user_id(self.id)
      pref = Preference.create(:user_id=>self.id) if pref.blank?
      return pref
    end

    # 该用户是否激活？（邮件激活，目前未启用）
    def activated?
      !activated_at.blank?
    end

    # 该用户是否admin用户？
    def is_admin_user?
      ADMIN_USER_EMAILS.include?(self.email)
    end

    # 该用户是否admin用户？ 同 is_admin_user?
    def is_admin?
      is_admin_user?
    end
  end

  module ClassMethods
    # 根据传入的邮箱名和密码进行用户验证
    def authenticate(email, password)
      user = User.find_by_email(email)
      if !!user
        expected_password = encrypted_password(password, user.salt)
        if user.hashed_password != expected_password
          user = nil
        end
      end
      user
    end

    # 电子邮箱或用户名 认证
    def authenticate2(email_or_name, password)
      user = self.authenticate(email_or_name, password)
      if user.blank?
        User.find_all_by_name(email_or_name).each do |u|
          expected_password = encrypted_password(password, u.salt)
          if u.hashed_password == expected_password
            return u
          end
        end
      end
      return user
    end

    # 验证cookies令牌
    def authenticate_cookies_token(token)
      t = token.split(':')
      user = User.find_by_email(t[0])
      if user
        if t[2] != hashed_token_string(user.email, user.hashed_password)
          user=nil
        end
      end
      user
    end

    # 使用SHA1算法，根据内部密钥和明文密码计算加密后的密码
    def encrypted_password(password, salt)
      Digest::SHA1.hexdigest(password + 'jerry_sun' + salt)
    end

    # 使用SHA1算法生成令牌字符串
    def hashed_token_string(name, hashed_password)
      Digest::SHA1.hexdigest(name + hashed_password + 'onlyecho')
    end
  end

end
