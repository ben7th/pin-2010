class WorkspaceAbstract < ActiveRecord::Base
  self.abstract_class = true
  build_database_connection("pin-workspace")
end
