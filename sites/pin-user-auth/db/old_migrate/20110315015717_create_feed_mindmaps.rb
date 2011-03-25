class CreateFeedMindmaps < ActiveRecord::Migration
  def self.up
    create_table :feed_mindmaps do |t|
      t.integer :feed_id
      t.integer :mindmap_id
      t.timestamps
    end
  end

  def self.down
    drop_table :feed_mindmaps
  end
end
