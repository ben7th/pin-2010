class Workspace < ActiveRecord::Base
  set_readonly(true)
  build_database_connection("pin-workspace")

  belongs_to :user

  
end
