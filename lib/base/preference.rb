class Preference < ActiveRecord::Base
  build_database_connection(CoreService::USER_AUTH)
  
  ALL_USERS = "all_users"
  ONLY_CONTACTS = "only_contacts"

  if RAILS_ENV == "test" && !self.table_exists?
    self.connection.create_table :preferences, :force => true do |t|
      t.integer  "user_id",:null => false
      t.string   "messages_set"
    end
  end

  module UserMethods
    def can_send_message_to?(user)
      return true if user.preference.messages_set == ALL_USERS
      user.following?(self)
    end
  end

end