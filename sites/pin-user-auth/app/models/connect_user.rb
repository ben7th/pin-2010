class ConnectUser < ActiveRecord::Base
  belongs_to :user

  TSINA_CONNECT_TYPE = "tsina"
  RENREN_CONNECT_TYPE = "renren"
  COMMON = "common"
  BIND = "bind"

  validates_presence_of :connect_id
  validates_presence_of :connect_type
  validates_presence_of :user_id

  def validate_on_create
    cu = ConnectUser.find_by_connect_type_and_connect_id(self.connect_type,self.connect_id)
    errors.add(:base,"重复绑定") if !cu.blank?
    cu = ConnectUser.find_by_connect_type_and_user_id(self.connect_type,self.user_id)
    errors.add(:base,"重复绑定") if !cu.blank?
  end

  def connect_type_str
    case self.connect_type
    when ConnectUser::TSINA_CONNECT_TYPE then "新浪微博账号"
    when ConnectUser::RENREN_CONNECT_TYPE then "人人网账号"
    end
  end

  def has_two_accounts?
    !!self.user_id && !!self.old_user_id
  end

  def self.bind_tsina_connect_user(connect_id,user,tsina_user_info,oauth_token,oauth_token_secret)
    connect_user = ConnectUser.find_by_connect_type_and_connect_id(TSINA_CONNECT_TYPE,connect_id)
    raise "这个新浪微博账号 已经被绑定过了" if !connect_user.blank?
    raise "这个用户已经绑定了其他新浪微博账号" if !user.tsina_connect_user.blank?
    connect_user = ConnectUser.create(
      :user_id=>user.id,:connect_type=>TSINA_CONNECT_TYPE,:connect_id=>connect_id,
      :oauth_token=>oauth_token,:oauth_token_secret=>oauth_token_secret,
      :account_detail=>tsina_user_info.to_json
    )
    url = self.get_tsina_user_big_logo_url_by_profile_image_url(tsina_user_info["profile_image_url"])
    user.update_logo_by_url_when_blank(url)
    connect_user
  end

  def self.bind_renren_connect_user(connect_id,user,renren_user_info,atoken)
    connect_user = ConnectUser.find_by_connect_type_and_connect_id(RENREN_CONNECT_TYPE,connect_id)
    raise "这个人人账号 已经被绑定过了" if !connect_user.blank?
    raise "这个用户已经绑定了其他人人账号" if !user.renren_connect_user.blank?
    connect_user = ConnectUser.create(
      :user_id=>user.id,:connect_type=>RENREN_CONNECT_TYPE,:connect_id=>connect_id,
      :oauth_token=>atoken,:account_detail=>renren_user_info.to_json
    )
    user.update_logo_by_url_when_blank(renren_user_info["logo_url"])
    connect_user
  end

  # 根据 connect_id 找到或创建 一个 tsina_connect_user
  # 并把 这个新浪微博账号的一些个人信息和 access_token access_token_secret 更新到 connect_user 上
  def self.create_tsina_connect_user(connect_id,user_name,tsina_user_info,oauth_token,oauth_token_secret)
    cu = self.create_quick_connect_account(TSINA_CONNECT_TYPE,connect_id,user_name)
    cu.update_tsina_info(tsina_user_info,oauth_token,oauth_token_secret)
    cu
  end

  def update_tsina_info(tsina_user_info,oauth_token,oauth_token_secret)
    raise "这个 connect_user 不是 tsina 类型" if self.connect_type != TSINA_CONNECT_TYPE
    self.update_attributes(:oauth_token=>oauth_token,:oauth_token_secret=>oauth_token_secret,:account_detail=>tsina_user_info.to_json)
    url = ConnectUser.get_tsina_user_big_logo_url_by_profile_image_url(tsina_user_info["profile_image_url"])
    self.user.update_logo_by_url_when_blank(url)
  end

  # 根据 connect_id 找到或创建 一个 renren_connect_user
  # 并把 这个人人账号的一些个人信息和 access_token 更新到 connect_user 上
  def self.create_renren_connect_user(connect_id,user_name,renren_user_info,atoken)
    cu = self.create_quick_connect_account(RENREN_CONNECT_TYPE,connect_id,user_name)
    cu.update_renren_info(renren_user_info,atoken)
    cu
  end

  def update_renren_info(renren_user_info,atoken)
    raise "这个 connect_user 不是 renren 类型" if self.connect_type != RENREN_CONNECT_TYPE
    self.update_attributes(:oauth_token=>atoken,:account_detail=>renren_user_info.to_json)
    self.user.update_logo_by_url_when_blank(renren_user_info["logo_url"])
  end

  # 根据 type connect_id 找到或创建 一个 connect_user
  def self.create_quick_connect_account(type,connect_id,user_name)
    connect_user = ConnectUser.find_by_connect_type_and_connect_id(type,connect_id)
    raise "#{type}:#{connect_id}已经存在" if connect_user
    user = User.new(:name=>user_name)
    user.save(false)
    connect_user = ConnectUser.create(:user_id=>user.id,:connect_type=>type,:connect_id=>connect_id)
    user.email = EmailActor.get_mindpin_email(user)
    user.save(false)
    return connect_user
  end

  def self.get_tsina_user_big_logo_url_by_profile_image_url(url)
    url.gsub("/50/","/180/")
  end

  def link(link_user)
    old_user_id = self.user_id
    self.update_attributes(:old_user_id=>old_user_id,:user_id=>link_user.id)
  end

  def unbind
    if !!self.old_user_id && !!self.user_id
      id = self.old_user_id
      self.update_attributes(:user_id=>id,:old_user_id=>nil)
    end
  end

  def update_account_detail
    if self.connect_type == ConnectUser::TSINA_CONNECT_TYPE
      tsina_user_info = Tsina.get_tsina_user_info_by_access_token(self.oauth_token,self.oauth_token_secret)
      self.update_attributes(:account_detail=>tsina_user_info.to_json)
      return
    end
    if self.connect_type == ConnectUser::RENREN_CONNECT_TYPE
      renren_user_info = RenRen.new.get_user_info(self.oauth_token)
      self.update_attributes(:account_detail=>renren_user_info.to_json)
    end
  end

  module UserMethods
    def tsina_wb
      cu = ConnectUser.find_by_user_id_and_connect_type(self.id,ConnectUser::TSINA_CONNECT_TYPE)
      return false if cu.blank? || cu.oauth_token.blank? || cu.oauth_token_secret.blank?
      require "weibo"
      Weibo::Config.api_key = Tsina::API_KEY
      Weibo::Config.api_secret = Tsina::API_SECRET
      oauth = Weibo::OAuth.new(Weibo::Config.api_key,Weibo::Config.api_secret)
      oauth.authorize_from_access(cu.oauth_token ,cu.oauth_token_secret)
      wb = Weibo::Base.new(oauth)
    end

    def send_message_to_tsina_weibo(content)
      cu = ConnectUser.find_by_user_id_and_connect_type(self.id,ConnectUser::TSINA_CONNECT_TYPE)
      return false if cu.blank? || cu.oauth_token.blank? || cu.oauth_token_secret.blank?
      require "weibo"
      Weibo::Config.api_key = Tsina::API_KEY
      Weibo::Config.api_secret = Tsina::API_SECRET
      oauth = Weibo::OAuth.new(Weibo::Config.api_key,Weibo::Config.api_secret)
      oauth.authorize_from_access(cu.oauth_token ,cu.oauth_token_secret)
      wb = Weibo::Base.new(oauth)
      wb.update(content)
      return true
    rescue Exception=>ex
      p ex.message
      puts ex.backtrace*"\n"
      return false
    end

    def send_mindmap_thumb_to_tsina_weibo(mindmap,content)
      image = MindmapImageCache.new(mindmap).get_img_path_by("500x500")
      send_tsina_image_status(image,content)
    end

    def send_tsina_image_status(image,content)
      cu = ConnectUser.find_by_user_id_and_connect_type(self.id,ConnectUser::TSINA_CONNECT_TYPE)
      return false if cu.blank? || cu.oauth_token.blank? || cu.oauth_token_secret.blank?
      require "weibo"
      Weibo::Config.api_key = Tsina::API_KEY
      Weibo::Config.api_secret = Tsina::API_SECRET
      oauth = Weibo::OAuth.new(Weibo::Config.api_key,Weibo::Config.api_secret)
      oauth.authorize_from_access(cu.oauth_token ,cu.oauth_token_secret)
      wb = Weibo::Base.new(oauth)
      File.open(image,"r") do |f|
       wb.upload(content,f)
      end
      return true
    rescue Exception=>ex
      p ex.message
      puts ex.backtrace*"\n"
      return false
    end

    def account_type
      cu = ConnectUser.find_by_user_id(self.id)
      return COMMON if cu.blank?
      if EmailActor.get_mindpin_email(self) == self.email
        return cu.connect_type
      end
      BIND
    end

    # 该账号是否是一个 本地mindpin 账号
    def is_mindpin_typical_account?
      !self.hashed_password.blank? &&
        EmailActor.get_mindpin_email(self) != self.email
    end

    # 该账号是否是一个快速连接账号
    def is_quick_connect_account?
      cu_1 = ConnectUser.find_by_user_id(self.id)
      cu_2 = ConnectUser.find_by_old_user_id(self.id)
      cu = cu_1 || cu_2
      return false if cu.blank?
      EmailActor.get_mindpin_email(self) == self.email
    end

    # 快速链接账号 登录后，没有设置邮箱和密码，也没有绑定 本地 mindpin 账号
    # 该账号是否是一个这种类型的账号
    def is_unlink_quick_connect_account?
      return false if EmailActor.get_mindpin_email(self) != self.email
      cu = ConnectUser.find_by_user_id(self.id)
      return false if cu.blank?
      cu.old_user_id.blank?
    end

    # 快速链接账号 登录后，绑定了 本地 mindpin 账号，
    # 该账号是否是其中的快速链接账号
    def is_link_quick_connect_account?
      cu = ConnectUser.find_by_old_user_id(self.id)
      return false if cu.blank?
      EmailActor.get_mindpin_email(self) == self.email
    end

    # 是否是 绑定了renren账号 的 本地mindpin账号
    def has_bind_renren_mindpin_account?
      is_mindpin_typical_account? &&
        !ConnectUser.find_by_user_id_and_connect_type(self.id,ConnectUser::RENREN_CONNECT_TYPE).blank?
    end

    # 取到该账号关联的 人人快速连接账号
    def get_link_renren_quick_connect_account
      cu = ConnectUser.find_by_user_id_and_connect_type(self.id,ConnectUser::RENREN_CONNECT_TYPE)
      return if cu.blank? || cu.old_user_id.blank?
      User.find_by_id(cu.old_user_id)
    end

    # 取到该账号关联的 tsina快速连接账号
    def get_link_tsina_quick_connect_account
      cu = ConnectUser.find_by_user_id_and_connect_type(self.id,ConnectUser::TSINA_CONNECT_TYPE)
      return if cu.blank? || cu.old_user_id.blank?
      User.find_by_id(cu.old_user_id)
    end

    def unbind_tsina_account
      return if self.get_link_tsina_quick_connect_account
      cu_1 = ConnectUser.find_by_user_id_and_connect_type(self.id,ConnectUser::TSINA_CONNECT_TYPE)
      cu_2 = ConnectUser.find_by_old_user_id_and_connect_type(self.id,ConnectUser::TSINA_CONNECT_TYPE)
      cu_1.destroy if cu_1
      cu_2.destroy if cu_2
    end

    def unbind_renren_account
      return if self.get_link_renren_quick_connect_account
      cu_1 = ConnectUser.find_by_user_id_and_connect_type(self.id,ConnectUser::RENREN_CONNECT_TYPE)
      cu_2 = ConnectUser.find_by_old_user_id_and_connect_type(self.id,ConnectUser::RENREN_CONNECT_TYPE)
      cu_1.destroy if cu_1
      cu_2.destroy if cu_2
    end

    # 从数据库获取新浪微博账号信息（HASH）
    def tsina_account_info
      cu = ConnectUser.find_by_user_id_and_connect_type(self.id,ConnectUser::TSINA_CONNECT_TYPE)
      return ActiveSupport::JSON.decode(cu.account_detail) if !!cu && !!cu.account_detail
    end

    # 从数据库获取人人网账号信息（HASH）
    def renren_account_info
      cu = ConnectUser.find_by_user_id_and_connect_type(self.id,ConnectUser::RENREN_CONNECT_TYPE)
      return ActiveSupport::JSON.decode(cu.account_detail) if !!cu && !!cu.account_detail
    end

    # 获取新浪微博连接对象（如果绑定，未绑定则返回nil）
    def tsina_connect_user
      return ConnectUser.find_by_user_id_and_connect_type(self.id,ConnectUser::TSINA_CONNECT_TYPE)
    end

    # 获取人人网连接对象（如果绑定，未绑定则返回nil）
    def renren_connect_user
      return ConnectUser.find_by_user_id_and_connect_type(self.id,ConnectUser::RENREN_CONNECT_TYPE)
    end

    # 是否绑定了新浪微博？（不管账号是什么类型）
    def has_binded_sina?
      !!tsina_connect_user
    end

    # 是否绑定了人人网？（不管账号是什么类型）
    def has_binded_renren?
      !!renren_connect_user
    end

    def update_logo_by_url_when_blank(logo_url)
      if self.logo.path.blank?
        self.logo = open(logo_url)
        self.save(false)
      end
    end
  end
end
