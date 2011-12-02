class CreateLoginWallpapers < ActiveRecord::Migration
  def self.up
    create_table :login_wallpapers do |t|
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.text :image_meta
      t.string :title
      t.timestamps
    end
  end

  def self.down
    drop_table :login_wallpapers
  end
end
