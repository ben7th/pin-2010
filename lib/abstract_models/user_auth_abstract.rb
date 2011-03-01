class UserAuthAbstract < ActiveRecord::Base
  self.abstract_class = true
  build_database_connection(CoreService::USER_AUTH)
end

