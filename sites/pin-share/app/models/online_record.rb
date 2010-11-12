class OnlineRecord < ActiveRecord::Base
  build_database_connection(CoreService::USER_AUTH)
end
