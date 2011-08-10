class CreateFeedPhotos < ActiveRecord::Migration
  def self.up
    create_table :feed_photos do |t|
      t.integer   :feed_id
      t.integer :photo_id
      t.timestamps
    end
  end

  def self.down
    drop_table :feed_photos
  end
end
