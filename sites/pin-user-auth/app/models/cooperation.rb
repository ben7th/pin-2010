class Cooperation < ActiveRecord::Base

  set_readonly(true)
  build_database_connection("pin-mindmap-editor")

  EDITOR = "editor"
  VIEWER = "viewer"

  belongs_to :mindmap

end
