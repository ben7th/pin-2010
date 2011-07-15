require 'digest/sha1'
require 'uuidtools'
require 'RMagick'
module UserMethods
  def self.included(base)
    base.set_readonly false

    # 缓存策略
    base.index :email

    # 在线状态记录
    base.has_one :online_record,:dependent => :destroy

    # 校验部分
    # 不能为空的有：用户名，登录名，电子邮箱
    # 不能重复的有：登录名，电子邮箱
    # 用户名：是2-20位的中文或者英文，但是两者不能混用
    # 两次密码输入必须一样，电子邮箱格式必须正确
    # 密码允许为空，但是如果输入了，就必须是4-32
    base.validates_presence_of :name
    base.validates_presence_of :email
    base.validates_uniqueness_of :email,:case_sensitive=>false,:on=>:create
    base.validates_format_of :email,:with=>/^([A-Za-z0-9_]+)([\.\-\+][A-Za-z0-9_]+)*(\@[A-Za-z0-9_]+)([\.\-][A-Za-z0-9_]+)*(\.[A-Za-z0-9_]+)$/
    # 用户名
    # 从可以是纯中文或纯英文的限制
    # 改为可以是中英文混写
    #base.validates_format_of :name,:with=>/^([A-Za-z0-9]{1}[A-Za-z0-9_]+)$|^([一-龥]+)$/
    base.validates_format_of :name,:with=>/^([A-Za-z0-9一-龥]+)$/
    base.validates_length_of :name, :in => 2..20
    base.validates_uniqueness_of :name,:case_sensitive=>false

    base.validates_presence_of :password,:on=>:create
    base.validates_presence_of :password_confirmation,:on=>:create
    base.send(:attr_accessor,:password_confirmation)
    base.validates_confirmation_of :password
    base.validates_length_of :password, :in => 4..32, :allow_blank=>true

    base.named_scope :recent,lambda{|*args|
      {:limit=>args.first||5}
    }

    base.named_scope :reputation_rank,:conditions=>"users.reputation != 0",
      :order=>"reputation desc"

    base.named_scope :feeds_rank,:conditions=>"feeds.hidden is not true",
      :joins=>"inner join feeds on feeds.creator_id = users.id",
      :group=>"users.id",:order=>"count(*) desc"

    base.named_scope :viewpoints_rank,:joins=>"inner join viewpoints on viewpoints.user_id = users.id",
      :group=>"users.id",:order=>"count(*) desc"

    base.send(:include,Fav::UserMethods)
    base.send(:include,Feed::UserMethods)
    base.send(:include,Viewpoint::UserMethods)
    base.send(:include,UserCooperationMethods)
    base.send(:include,Channel::UserMethods)
    base.send(:include,Contact::UserMethods)
    base.send(:include,ChannelContact::UserMethods)
    base.send(:include,ConnectUser::UserMethods)
    base.send(:include,Tsina::UserMethods)
    base.send(:include,MindmapFav::UserMethods)
    base.send(:include,MindmapComment::UserMethods)
    base.send(:include,FeedInvite::UserMethods)
    base.send(:include,UserLog::UserMethods)
    base.send(:include,TagFav::UserMethods)
    base.send(:include,TagsMapOfUserCreatedFeedsProxy::UserMethods)
    base.send(:include,TagsMapOfUserMemoedFeedsProxy::UserMethods)
    base.send(:include,Atme::UserMethods)
    base.send(:include,ReputationLog::UserMethods)
  end


  def validate_on_create
    if !self.email.gsub("@mindpin.com").to_a.blank?
      errors.add(:email,"邮箱格式不符规范")
    end
  end

  def validate_on_update
    if !self.email.gsub("@mindpin.com").to_a.blank?
      if !self.is_quick_connect_account?
        errors.add(:email,"邮箱格式不符规范")
      end
    end
  end

  # 是否需要 修改用户名 用户名不合法
  def need_change_name?
    valid?
    errors.invalid?(:name)
  end

  # 判断该用户在系统中是否有同名
  # 如果有就在名字后加 1 ，如果依然同名 加 2 依次类推
  def change_name_when_need!
    return unless self.need_change_name?

    old_name = self.name
    i = 1
    while self.need_change_name?
      self.name = "#{old_name}#{i}"
      i += 1
    end
    self.save!
  end

  ###
  # 创建cookies登录令牌
  def create_cookies_token(expire)
    value=self.email+':'+expire.to_s+':'+User.hashed_token_string(self.email,self.hashed_password)
    {:value=>value,:expires=>expire.days.from_now,:domain=>ActionController::Base.session_options[:domain]}
  end

  def password
    @password
  end

  # 根据传入的明文密码，创建内部密钥并计算密文密码
  def password=(pwd)
    @password=pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password=User.encrypted_password(self.password,self.salt)
  end

  # 创建注册激活码
  def create_activation_code
    self.activation_code = UUIDTools::UUID.random_create.to_s
  end

  # 发送激活邮件
  def send_activation_mail
    self.create_activation_code if self.reload.activation_code.blank?
    self.save(false)
    UserObserver.instance.send_activation_mail(self)
  end

  # 激活
  def activate
    self.activation_code = nil
    self.activated_at = Time.now
    self.save(false)
  end

  # 密码重设，并发送邮件
  def forgot_password
    @forgotten_password = true
    self.make_password_reset_code
    self.save(false)
    Mailer.deliver_forgotpassword(self)
  end

  protected
  def make_password_reset_code
    self.reset_password_code = Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by{rand}.join)
    self.reset_password_code_until = Time.now.next_year
  end

  # 随机生成内部密钥
  private
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

  public
  def copper_logo(image_file_path, params)
    file = File.new(image_file_path)
    self.update_attributes(:logo=>file)
    file = File.new(image_file_path)
    img = Magick::Image::read(file).first
    img.crop!(params[:x1].to_i, params[:y1].to_i,params[:width].to_i, params[:height].to_i,true)
    _resize(img)
  end

  def _resize(img)
    #    {:raw=>'500x500>',:medium=>"96x96#",:normal=>"48x48#",:tiny=>'32x32#',:mini=>'24x24#' }
    _resize_logo(img,"medium",96,96)
    _resize_logo(img,"normal",48,48)
    _resize_logo(img,"tiny",32,32)
    _resize_logo(img,"mini",24,24)
  end

  def _resize_logo(img,type,width,height)
    img_type = img.resize(width,height)
    img_type.write File.expand_path(UserBase::LOGO_PATH_ROOT)+"/users/logos/#{self.id}/#{type}/#{self.logo_file_name}"
  end

  def change_password(old_pass,new_pass,new_pass_confirmation)
    raise "请输入旧密码" if old_pass.blank?
    raise "请输入新密码" if new_pass.blank?
    raise "请输入确认新密码" if new_pass_confirmation.blank?
    raise "新密码和确认新密码输入不相同" if new_pass_confirmation != new_pass
    user = User.authenticate(self.email,old_pass)
    raise "旧密码输入错误" if self.id != user.id
    user.password=new_pass
    user.password_confirmation=new_pass_confirmation
    user.save!
  end

end
