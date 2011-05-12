class CreateFeedTags < ActiveRecord::Migration
  def self.up
    create_table :feed_tags do |t|
      t.integer :feed_id
      t.string :tag_name
      t.timestamps
    end
  end

  def self.down
    drop_table :feed_tags
  end
end
