class CreateMindmapAlbums < ActiveRecord::Migration
  def change
    create_table :mindmap_albums do |t|
      t.integer :user_id
      t.string :title
      t.string :send_status    
      t.timestamps
    end
  end
end
