class ChangeDraftPhotoNamesToIds < ActiveRecord::Migration
  def self.up
    rename_column(:post_drafts, :photo_names, :photo_ids)
  end

  def self.down
  end
end
