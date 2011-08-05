class CreateFeedCollections < ActiveRecord::Migration
  def self.up
    create_table :feed_collections do |t|
      t.integer :feed_id
      t.integer :collection_id
      t.timestamps
    end
  end

  def self.down
    drop_table :feed_collections
  end
end
