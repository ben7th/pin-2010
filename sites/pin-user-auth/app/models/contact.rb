class Contact < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :user_id
  validates_presence_of :email
  validates_format_of :email,:with=>/^([A-Za-z0-9_]+)([\.\-\+][A-Za-z0-9_]+)*(\@[A-Za-z0-9_]+)([\.\-][A-Za-z0-9_]+)*(\.[A-Za-z0-9_]+)$/

  def validate
    errors.add("email","已添加该联系人") if user.contacts_email.include?(email)
    errors.add("email","联系人不能添加自己") if email == user.email
  end

  def contact_user
    user = User.find_by_email(email)
    return user.blank? ? nil : user
  end

  module UserMethods
    def self.included(base)
      base.has_many :contacts
    end

    def contacts_email
      contacts.map{|c|c.email}
    end
  end
end
