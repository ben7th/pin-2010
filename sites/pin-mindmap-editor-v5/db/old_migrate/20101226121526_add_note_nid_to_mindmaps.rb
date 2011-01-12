class AddNoteNidToMindmaps < ActiveRecord::Migration
  def self.up
    add_column :mindmaps,:note_nid,:string
  end

  def self.down
  end
end
