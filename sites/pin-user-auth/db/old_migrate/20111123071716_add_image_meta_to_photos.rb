class AddImageMetaToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :image_meta,    :text
  end

  def self.down
  end
end
