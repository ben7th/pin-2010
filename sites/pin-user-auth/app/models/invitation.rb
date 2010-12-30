class Invitation < ActiveRecord::Base
  belongs_to :user,:class_name => "User",:foreign_key => "host_email",:primary_key=>"email"

  validates_presence_of :host_email
  validates_format_of :host_email,:with=>/^([A-Za-z0-9_]+)([\.\-\+][A-Za-z0-9_]+)*(\@[A-Za-z0-9_]+)([\.\-][A-Za-z0-9_]+)*(\.[A-Za-z0-9_]+)$/

  validates_presence_of :contact_email
  validates_format_of :contact_email,:with=>/^([A-Za-z0-9_]+)([\.\-\+][A-Za-z0-9_]+)*(\@[A-Za-z0-9_]+)([\.\-][A-Za-z0-9_]+)*(\.[A-Za-z0-9_]+)$/

  validates_presence_of :code

  # 创建之前，设置code
  before_validation_on_create :set_code
  def set_code
    self.activated = false
    self.code = randstr
    return true
  end

  def validate_on_create
    if EmailActor.new(self.contact_email).signed_in?
      self.errors.add(:contact_email,"被邀请邮箱已经注册过了")
    end
  end

  # 发送邀请函
  after_create :send_invite_email
  def send_invite_email
    Thread.start{Mailer.deliver_invitation(self)}
  end

  # 被邀请人 注册成功后 互相加为联系人
  def add_contacts
    self.user.concats.create(:email=>self.contact_email)
    User.find_by_email(self.contact_email).concats.create(:email=>self.host_email)
    self.update_attribute("activated", true)
  end

  require 'contacts_cn'
  def self.fetch_email_contacts(login, password, type)
    name_and_emails = case type
    when "hotmail"
      Contacts::Hotmail.new(login, password).contacts # => [["name", "foo@bar.com"], ["another name", "bow@wow.com"]]
    when "aol"
      Contacts::Aol.new(login, password).contacts
    when "gmail"
      Contacts::Gmail.new(login, password).contacts
    when "plaxo"
      Contacts::Plaxo.new(login, password).contacts
    when "126"
      Contacts::NetEase.new(login,password).contacts
    when "163"
      Contacts::NetEase.new(login,password).contacts
    when "yeah"
      Contacts::NetEase.new(login,password).contacts
    when "sina"
      Contacts::Sina.new(login,password).contacts
    when "sohu"
      Contacts::Sohu.new(login, password).contacts
    when "yahoo"
      Contacts::Yahoo.new(login, password).contacts
    end
    name_and_emails.map do |name_and_email|
      name_and_email[1]
    end
  end

  class ContactEmailUsedError < StandardError;end

end
