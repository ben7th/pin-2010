class CreateViewpointDrafts < ActiveRecord::Migration
  def self.up
    create_table :viewpoint_drafts do |t|
      t.integer :user_id
      t.integer :feed_id
      t.text :content
      t.timestamps
    end
  end

  def self.down
    drop_table :viewpoint_drafts
  end
end
