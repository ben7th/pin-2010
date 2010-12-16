class Mindmap < ActiveRecord::Base
  belongs_to :user
  set_readonly(true)
  build_database_connection("pin-mindmap-editor")
  
end
