class ActivationCode < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :code
  validates_uniqueness_of :code,:case_sensitive=>false

  scope :unused,:conditions=>"user_id is null"

  def self.unused_codes
    self.unused.map{|ac|ac.code}
  end

  def self.generate(count=10)
    1.upto(count){self.generate_one_code}
  end

  def self.generate_one_code
    code = randstr(16).downcase
    if self.find_by_code(code).blank?
      self.create(:code=>code)
    else
      self.generate_one_code
    end
  end

  def self.is_v2_activation_user?(user)
    !ActivationCode.find_by_user_id(user.id).blank?
  end

  def self.acitvate_user(code,user)
    raise "激活前请先登录" if user.blank?
    ac = ActivationCode.find_by_code(code)
    raise "激活码不正确" if ac.blank?
    raise "激活码已经被使用过了" unless ac.user_id.blank?
    ac.update_attributes(:user_id=>user.id)
  end

  module UserMethods
    def is_v2_activation_user?
      ActivationCode.is_v2_activation_user?(self)
    end
  end

end
