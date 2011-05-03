class AddChannelIdToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations,:channel_id,:integer
  end

  def self.down
  end
end
