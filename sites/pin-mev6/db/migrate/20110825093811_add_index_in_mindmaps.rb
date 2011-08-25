class AddIndexInMindmaps < ActiveRecord::Migration
  def self.up
    add_index :mindmaps, :send_status
  end

  def self.down
  end
end
