class Concat < ActiveRecord::Base
  set_readonly(true)
  build_database_connection("user_auth")

  belongs_to :user

  def concat_user
    user = User.find_by_email(email)
    return user.blank? ? nil : user
  end

  def concat_user_name
    return '' if concat_user.blank?
    concat_user.name
  end
end