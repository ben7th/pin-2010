class AddSynFromConnectToConnectUser < ActiveRecord::Migration
  def self.up
    add_column :connect_users,:syn_from_connect,:boolean
  end

  def self.down
  end
end
