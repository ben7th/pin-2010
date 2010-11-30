# == Schema Information
# Schema version: 20091223090135
#
# Table name: users
#
#  id                :integer(4)      not null, primary key
#  login             :string(255)     default(""), not null
#  name              :string(255)     default(""), not null
#  hashed_password   :string(255)     default(""), not null
#  salt              :string(255)     default(""), not null
#  email             :string(255)     default(""), not null
#  sign              :string(255)     
#  active_code       :string(255)     
#  activated         :boolean(1)      not null
#  logo_file_name    :string(255)     
#  logo_content_type :string(255)     
#  logo_file_size    :integer(4)      
#  logo_updated_at   :datetime        
#  created_at        :datetime        
#  updated_at        :datetime        
#

# == Schema Information
# Schema version: 20090707030914
#
# Table name: users
#
#  id                :integer(4)      not null, primary key
#  name              :string(255)     default(""), not null
#  hashed_password   :string(255)     default(""), not null
#  salt              :string(255)     default(""), not null
#  email             :string(255)     default(""), not null
#  sign              :string(255)     
#  created_at        :datetime        
#  updated_at        :datetime        
#  active_code       :string(255)     
#  activated         :boolean(1)      not null
#  logo_file_name    :string(255)     
#  logo_content_type :string(255)     
#  logo_file_size    :integer(4)      
#  logo_updated_at   :datetime        
#  role              :string(255)     default("NORMAL")
#

require 'digest/sha1'
require 'uuidtools'
require 'RMagick'

class User < UserBase
  set_readonly false
  
  # 在线状态记录
  has_one :online_record,:dependent => :destroy

  # 校验部分
  # 不能为空的有：用户名，登录名，电子邮箱
  # 不能重复的有：登录名，电子邮箱
  # 用户名：是2-20位的中文或者英文，但是两者不能混用
  # 两次密码输入必须一样，电子邮箱格式必须正确
  # 密码允许为空，但是如果输入了，就必须是4-32
  validates_presence_of :name
  validates_presence_of :email
  validates_uniqueness_of :email,:case_sensitive=>false,:on=>:create
  validates_format_of :email,:with=>/^([A-Za-z0-9_]+)([\.\-\+][A-Za-z0-9_]+)*(\@[A-Za-z0-9_]+)([\.\-][A-Za-z0-9_]+)*(\.[A-Za-z0-9_]+)$/

  validates_format_of :name,:with=>/^([A-Za-z0-9]{1}[A-Za-z0-9_]+)$|^([一-龥]+)$/
  validates_length_of :name, :in => 2..20

  validates_presence_of :password,:on=>:create
  validates_presence_of :password_confirmation,:on=>:create
  attr_accessor :password_confirmation
  validates_confirmation_of :password
  validates_length_of :password, :in => 4..32, :allow_blank=>true

  named_scope :recent,lambda{|*args|
    {:limit=>args.first||5}
  }

  # 创建cookies登录令牌
  def create_cookies_token(expire)
    value=self.name+':'+expire.to_s+':'+User.hashed_token_string(self.name,self.hashed_password)
    {:value=>value,:expires=>expire.days.from_now,:domain=>'mindpin.com'}
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
    self.create_activation_code if self.activation_code.blank?
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
    UserObserver.instance.send_forgotpassword_mail(self)
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

  def copper_logo(params)
    img = Magick::Image::read(File.new(self.logo.path(:raw))).first
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
    img_type.write File.expand_path(LOGO_PATH_ROOT)+"/users/logos/#{self.id}/#{type}/#{self.logo_file_name}"
  end

  has_many :workspaces

  include Member::UserMethods
  include Organization::UserMethods
  include Concat::UserMethods
  include Activity::UserMethods
end