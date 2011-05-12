class Contact < UserAuthAbstract
  set_readonly(false)
  belongs_to :user
  belongs_to :follow_user,:class_name=>"User",:foreign_key=>"follow_user_id"
  
  validates_presence_of :user
  validates_presence_of :follow_user

  index :user_id

  def validate_on_create
    if follow_user
      con = user.get_contact_obj_of(follow_user)
      errors.add(:base,"已经添加过该联系人") if !con.blank?
      errors.add(:base,"不能添加自己为联系人") if follow_user == user
    end
  end

  def validate_on_update
    if follow_user
      con = user.get_contact_obj_of(follow_user)
      if !con.blank? && self.id != con.id
        errors.add(:base,"已经添加过该联系人")
      end
    end
  end

  def contact_user
    self.follow_user
  end

  def contact_user_name
    return '' if contact_user.blank?
    contact_user.name
  end


  module UserMethods
    def self.included(base)
      base.has_many :contacts
      base.has_many :followings_db,:through=>:contacts,:source=>:user
      base.has_many :fans_db,:through=>:contacts,:source=>:follow_user
    end
    
    def fans_contacts_db
      Contact.find_all_by_follow_user_id(self.id)
    end

    def get_contact_obj_of(follow_user)
      contacts = self.contacts.find_all_by_follow_user_id(follow_user.id)
      return contacts.first if !contacts.blank?
      return nil
    end

    def add_contact_user(follow_user)
      contact = Contact.new(:user=>self,:follow_user=>follow_user)
      contact.save
      contact
    end
  end

  include UserLog::ContactMethods
end
