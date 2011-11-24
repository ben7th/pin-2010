class RemoveMd5FromPhotoTmps < ActiveRecord::Migration
  def self.up
    remove_column :photo_tmps,:md5
  end

  def self.down
  end
end
