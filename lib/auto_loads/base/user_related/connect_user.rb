class ConnectUser < UserAuthAbstract
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
    user.save(:validate => false)
    connect_user = ConnectUser.create(:user_id=>user.id,:connect_type=>type,:connect_id=>connect_id)
    user.email = EmailActor.get_mindpin_email(user)
    user.save(:validate => false)
    return connect_user
  end

  def self.get_tsina_user_big_logo_url_by_profile_image_url(url)
    url.gsub("/50/","/180/")
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
  rescue Tsina::OauthFailureError=>ex
    self.record_oauth_token_is_invalid
    raise ex
  end

  def is_oauth_invalid?
    oauth_invalid?
  end

  def record_oauth_token_is_invalid
    self.update_attributes(:oauth_invalid=>true)
  end

  def set_syn_from_connect
    self.update_attributes(:syn_from_connect=>true)
  end

  def cancel_syn_from_connect
    self.update_attributes(:syn_from_connect=>false)
  end

  def record_last_syn_message_id(message_id)
    self.update_attributes(:last_syn_message_id=>message_id)
  end

  def self.get_user_from_tsina_id(id)
    user = nil
    cu = ConnectUser.find_by_connect_type_and_connect_id(TSINA_CONNECT_TYPE,id)
    user = cu.user unless cu.blank?
    user
  end

  module UserMethods
    # ---- 以上是微博相关，代码写得不好，重复地方太多。改一个字段名的话，照这种代码改起来会累死。重构
    # SONGLIANG

    # TODO 4月1日部署前务必过一遍这里，然后重新测试

    # 返回目前账号的类型描述标识
    # 如果是正式账号
    # 返回 common(未绑定任何) bind（绑定了至少一个第三方网站）
    #
    # 如果是快速连接账号
    # 返回 tsina(绑定了新浪微博) renren(绑定了人人网)
    def account_type
      cu = ConnectUser.find_by_user_id(self.id)
      return COMMON if cu.blank?
      if self.is_user_info_incomplete?
        return cu.connect_type
      end
      BIND
    end

    # 该账号是否是一个 mindpin正式账号
    def is_mindpin_typical_account?
      !is_user_info_incomplete?
    end

    def is_user_info_incomplete?
      self.hashed_password.blank? || self.email.blank?
    end

    # 尝试解除当前账号的新浪微博绑定，并删除绑定对象
    def unbind_tsina_account
      return if is_user_info_incomplete?
      cu = tsina_connect_user
      cu.destroy if cu
    end

    # 尝试解除当前账号的人人网绑定，并删除绑定对象
    def unbind_renren_account
      return if is_user_info_incomplete?
      cu = renren_connect_user
      cu.destroy if cu
    end

    # 从数据库获取新浪微博账号信息（HASH）
    def tsina_account_info
      cu = tsina_connect_user
      return ActiveSupport::JSON.decode(cu.account_detail) if !!cu && !!cu.account_detail
    end

    # 从数据库获取人人网账号信息（HASH）
    def renren_account_info
      cu = renren_connect_user
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

    def has_binded_tsina?
      has_binded_sina?
    end

    # 是否绑定了人人网？（不管账号是什么类型）
    def has_binded_renren?
      !!renren_connect_user
    end

    def update_logo_by_url_when_blank(logo_url)
      if self.logo.path.blank?
        self.logo = open(logo_url)
        self.save(:validate => false)
      end
    end
  end
end
