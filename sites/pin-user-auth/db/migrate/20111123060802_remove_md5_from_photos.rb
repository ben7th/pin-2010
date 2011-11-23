class RemoveMd5FromPhotos < ActiveRecord::Migration
  def self.up
    remove_column :photos,:md5
  end

  def self.down
  end
end
