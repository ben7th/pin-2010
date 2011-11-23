class AddImageFingerprintToPhotoTmps < ActiveRecord::Migration
  def self.up
    add_column :photo_tmps,:image_fingerprint,:string
  end

  def self.down
  end
end
