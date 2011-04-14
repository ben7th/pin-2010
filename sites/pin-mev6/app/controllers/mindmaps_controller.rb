class MindmapsController < ApplicationController
  include MindmapRightsHelper
  include MindmapEditorControllerMethods
  before_filter :per_load
  def per_load
    @mindmap = Mindmap.find(params[:id]) if params[:id]
  end

  def fav
    current_user.add_fav_mindmap(@mindmap)
    render :stats=>200,:text=>"收藏成功"
  end

  def unfav
    current_user.remove_fav_mindmap(@mindmap)
    render :stats=>200,:text=>"取消收藏成功"
  end
  
end
