class AlbumsController < ApplicationController
  before_filter :per_load
  def per_load
    @album = MindmapAlbum.find(params[:id]) if params[:id]
  end
  
  def create
    album = MindmapAlbum.new(:title=>params[:title],:send_status=>MindmapAlbum::SendStatus::PUBLIC)
    if album.save
      return render :text=>200
    end
    render :text=>411,:status=>411
  end
  
  def destroy
    @album.destroy
    render :text=>200
  end
  
  def update
    if @album.update_attribute(:title,params[:title])
      return render :text=>200
    end
    render :text=>411,:status=>411
  end
  
  def toggle_private
    @album.toggle_private
    render :text=>200
  end
  
  def movein
    mindmap = Mindmap.find(params[:mindmap_id])
    if mindmap.update_attribute(:mindmap_album_id=>@album.id)
      return render :text=>200
    end
    render :text=>411,:status=>411
  end
  
  def moveout
    mindmap = Mindmap.find(params[:mindmap_id])
    if mindmap.update_attribute(:mindmap_album_id=>nil)
      return render :text=>200
    end
    render :text=>411,:status=>411
  end
  
end
