class AddLocalVersionToMindmaps < ActiveRecord::Migration
  def self.up
    add_column :mindmaps, :lock_version, :integer, :default => 0
  end

  def self.down
  end
end
