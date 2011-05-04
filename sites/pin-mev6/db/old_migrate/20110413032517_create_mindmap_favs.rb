class CreateMindmapFavs < ActiveRecord::Migration
  def self.up
    create_table :mindmap_favs do |t|
      t.integer :user_id
      t.integer :mindmap_id
      t.timestamps
    end
  end

  def self.down
    drop_table :mindmap_favs
  end
end
