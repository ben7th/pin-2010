class Contact < UserAuthAbstract
  set_readonly(true)

  belongs_to :user

  def contact_user
    user = EmailActor.get_user_by_email(email)
    return user.blank? ? nil : user
  end

  def contact_user_name
    return '' if contact_user.blank?
    contact_user.name
  end
end