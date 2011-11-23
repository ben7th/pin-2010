class AddImageFingerprintToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos,:image_fingerprint,:string
  end

  def self.down
  end
end
