class ChangeFeedPhotos < ActiveRecord::Migration
  def self.up
    rename_table(:feed_photos,:post_photos)
    add_column(:post_photos,:post_id,:integer)
  end

  def self.down
  end
end
