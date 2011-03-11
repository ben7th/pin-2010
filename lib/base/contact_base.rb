class ContactBase < UserAuthAbstract
  set_readonly(true)
  set_table_name("contacts")

  def contact_user
    user = EmailActor.get_user_by_email(self.email)
    return user.blank? ? nil : user
  end

  def contact_user_name
    return '' if contact_user.blank?
    contact_user.name
  end

  module UserMethods

    def contacts_user
      cap = ContactAttentionProxy.new(self)
      cts = cap.followings_contacts
      cts.map{|c|EmailActor.get_user_by_email(c.email)}.compact
    end

    def contacts_users
      contacts_user
    end

    def followings
      contacts_user
    end

    def following?(user)
      contacts_user.include?(user)
    end

    def contacts_email
      contacts.map{|c|c.email}
    end

    def fans
      fans_contacts.map{|contact|contact.user}.compact
    end

    # 当前用户的联系人包括自己
    def following_users
      cap = ContactAttentionProxy.new(self)
      cts = cap.followings_contacts
      cts.map{|c|EmailActor.get_user_by_email(c.email)}.compact + [self]
    end

    def fans_contacts
      cap = ContactAttentionProxy.new(self)
      cap.fans_contacts
    end

  end

end