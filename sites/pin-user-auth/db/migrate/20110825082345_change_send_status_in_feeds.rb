class ChangeSendStatusInFeeds < ActiveRecord::Migration
  def self.up
    change_column :feeds, :send_status, :string, :null=>false,:default =>"public"
    add_index :feeds, :send_status
  end

  def self.down
  end
end
