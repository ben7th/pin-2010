class AddSendStatusToCollections < ActiveRecord::Migration
  def self.up
    add_column :collections, :send_status, :string
  end

  def self.down
  end
end
