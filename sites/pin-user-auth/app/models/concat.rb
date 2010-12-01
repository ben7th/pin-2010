class Concat < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id
  validates_presence_of :email
  validates_format_of :email,:with=>/^([A-Za-z0-9_]+)([\.\-\+][A-Za-z0-9_]+)*(\@[A-Za-z0-9_]+)([\.\-][A-Za-z0-9_]+)*(\.[A-Za-z0-9_]+)$/

  def validate
    errors.add("email","已添加该联系人") if user.concats_email.include?(email)
    errors.add("email","联系人不能添加自己") if email == user.email
  end

  module UserMethods
    def self.included(base)
      base.has_many :concats
    end

    def concats_email
      concats.map{|c|c.email}
    end
  end
end