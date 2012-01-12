class ApplyRecord < ActiveRecord::Base
  belongs_to :activation_code,:class_name=>"ActivationCode",:foreign_key=>:code_id

    validates_presence_of :email
    validates_presence_of :name
    validates_presence_of :description
    validates_presence_of :activation_code

    scope :unactivated,:conditions=>"activation_codes.user_id is null",
      :joins=>"inner join activation_codes on activation_codes.id = apply_records.code_id"

    before_validation :create_a_activation_code, :on=>:create
    def create_a_activation_code
      self.activation_code = ActivationCode.generate_one_code
    end

  #对应的激活码是否已经激活
  def has_activated?
    !self.activation_code.user.blank?
  end

  #如果已经激活，返回对应的用户，否则返回nil
  def linked_user
    self.activation_code.user
  end

  #发送带有激活码的邮件（邮件模板请问我要）
  def send_email
    Mailer.apply_confirm(self.email,self.name,self.activation_code.code).deliver
  end

  def self.create_from_feed(feed)
    str = feed.detail
    str_arr = str.split("\n")
    email = str_arr[2]
    name = str_arr[5]
    description = str_arr[8]
    record = self.new(:email=>email,:name=>name,:description=>description,:created_at=>feed.created_at)
    record.save_without_timestamping
  end

end
