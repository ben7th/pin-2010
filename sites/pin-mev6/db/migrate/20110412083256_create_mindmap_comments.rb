class CreateMindmapComments < ActiveRecord::Migration
  def self.up
    create_table :mindmap_comments do |t|
      t.integer :mindmap_id
      t.integer :creator_id
      t.text :content
      t.timestamps
    end
  end

  def self.down
    drop_table :mindmap_comments
  end
end
