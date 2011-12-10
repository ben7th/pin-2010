class CreateMediaThumbnails < ActiveRecord::Migration
  def self.up
    create_table :media_thumbnails do |t|
      t.string :url
      t.string :thumb_src
      t.string :host
      t.string :time
      t.timestamps
    end
  end

  def self.down
    drop_table :media_thumbnails
  end
end
