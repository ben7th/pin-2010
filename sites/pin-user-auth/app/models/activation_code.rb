class ActivationCode < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :code
  validates_uniqueness_of :code,:case_sensitive=>false

  def self.generate(count=10)
    1.upto(count){self.generate_one_code}
  end

  def self.generate_one_code
    code = randstr.downcase
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
    ac = ActivationCode.find_by_code(code)
    return false if ac.blank?
    ac.update_attributes(:user_id=>user.id)
    return true
  end

  module UserMethods
    def is_v2_activation_user?
      ActivationCode.is_v2_activation_user?(self)
    end
  end

end
