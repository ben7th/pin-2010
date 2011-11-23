class DropPhotoTmps < ActiveRecord::Migration
  def self.up
    drop_table :photo_tmps
  end

  def self.down
  end
end
