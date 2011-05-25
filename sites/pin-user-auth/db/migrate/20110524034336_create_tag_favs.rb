class CreateTagFavs < ActiveRecord::Migration
  def self.up
    create_table :tag_favs do |t|
      t.integer :user_id
      t.integer :tag_id
      t.timestamps
    end
  end

  def self.down
    drop_table :tag_favs
  end
end
