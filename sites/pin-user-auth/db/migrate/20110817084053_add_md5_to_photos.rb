class AddMd5ToPhotos < ActiveRecord::Migration
  def self.up
    add_column(:photos, :md5, :string)
  end

  def self.down
  end
end
