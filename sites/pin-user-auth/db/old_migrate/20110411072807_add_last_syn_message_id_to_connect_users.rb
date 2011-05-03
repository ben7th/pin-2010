class AddLastSynMessageIdToConnectUsers < ActiveRecord::Migration
  def self.up
    add_column :connect_users,:last_syn_message_id,:string
  end

  def self.down
    remove_column :connect_users,:last_syn_message_id
  end
end
