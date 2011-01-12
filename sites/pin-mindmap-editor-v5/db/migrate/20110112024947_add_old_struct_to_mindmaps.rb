class AddOldStructToMindmaps < ActiveRecord::Migration
  def self.up
    add_column :mindmaps,:old_struct,:text
  end

  def self.down
  end
end
