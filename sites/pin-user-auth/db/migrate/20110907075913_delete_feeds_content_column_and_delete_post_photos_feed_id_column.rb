class DeleteFeedsContentColumnAndDeletePostPhotosFeedIdColumn < ActiveRecord::Migration
  def self.up
    remove_column(:feeds, :content)
    remove_column(:post_photos, :feed_id)
  end

  def self.down
  end
end
