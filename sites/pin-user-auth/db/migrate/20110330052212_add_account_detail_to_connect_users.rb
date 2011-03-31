class AddAccountDetailToConnectUsers < ActiveRecord::Migration
  def self.up
    add_column :connect_users,:account_detail,:text
  end

  def self.down
  end
end
