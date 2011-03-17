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

end