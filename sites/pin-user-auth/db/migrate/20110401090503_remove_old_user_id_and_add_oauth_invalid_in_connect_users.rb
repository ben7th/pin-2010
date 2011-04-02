class RemoveOldUserIdAndAddOauthInvalidInConnectUsers < ActiveRecord::Migration
  def self.up
    remove_column :connect_users,:old_user_id
    add_column :connect_users,:oauth_invalid,:boolean
  end

  def self.down
  end
end
