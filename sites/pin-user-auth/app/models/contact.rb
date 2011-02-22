class Contact < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :user_id
  validates_presence_of :email
  validates_format_of :email,:with=>/^([A-Za-z0-9_]+)([\.\-\+][A-Za-z0-9_]+)*(\@[A-Za-z0-9_]+)([\.\-][A-Za-z0-9_]+)*(\.[A-Za-z0-9_]+)$/

  index :user_id

  def validate
    add_user = EmailActor.get_user_by_email(email)
    errors.add("email","已添加该联系人") if user.contacts_user.include?(add_user)
    errors.add("email","联系人不能添加自己") if add_user.id == user.id
  end

  def contact_user
    user = EmailActor.get_user_by_email(email)
    return user.blank? ? nil : user
  end

  def contact_user_name
    return '' if contact_user.blank?
    contact_user.name
  end

  module UserMethods
    def self.included(base)
      base.has_many :contacts
    end

    def contacts_user
      cap = ContactAttentionProxy.new(self)
      cts = cap.followings_contacts
      cts.map{|c|EmailActor.get_user_by_email(c.email)}.compact
    end

    def following?(user)
      contacts_user.include?(user)
    end

    def contacts_email
      contacts.map{|c|c.email}
    end

    def fans
      fans_contacts.map{|contact|EmailActor.get_user_by_email(contact.user.email)}
    end

  end

  include ContactAttentionProxy::ContactMethods
end
