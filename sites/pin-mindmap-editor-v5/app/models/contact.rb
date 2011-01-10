class Contact < ActiveRecord::Base
  set_readonly(true)
  build_database_connection("user_auth")

  belongs_to :user

  def contact_user
    user = User.find_by_email(email)
    return user.blank? ? nil : user
  end

  def contact_user_name
    return '' if contact_user.blank?
    contact_user.name
  end
end