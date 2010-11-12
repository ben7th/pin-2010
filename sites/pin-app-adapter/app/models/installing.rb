class Installing < ActiveRecord::Base
  include Pacecar
  belongs_to :user
  belongs_to :app

  def validate_on_create
    if Installing.find_by_user_id_and_app_id(user.id,app.id)
      errors.add_to_base("不能重复创建")
    end
  end
end