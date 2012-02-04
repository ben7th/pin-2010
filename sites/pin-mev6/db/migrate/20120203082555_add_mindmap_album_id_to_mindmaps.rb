class AddMindmapAlbumIdToMindmaps < ActiveRecord::Migration
  def change
    add_column(:mindmaps, :mindmap_album_id,:integer)
  end
end
