class MindmapsController < ApplicationController
  include MindmapRightsHelper
  include MindmapEditorControllerMethods
  before_filter :per_load
  def per_load
    @mindmap = Mindmap.find(params[:id]) if params[:id]
  end

  def toggle_fav
    current_user.toggle_fav_mindmap(@mindmap)
    render :text=>@mindmap.faved_by?(current_user)
  rescue
    render :status=>503, :text=>'操作失败'
  end

  def refresh_thumb
    MindmapImageCache.new(@mindmap).refresh_all_cache_file

    size_param = params[:size_param] || "500x500"
    render :text=>@mindmap.thumb_image_url(size_param)
  end

  # destroy
  include MindmapManagingControllerMethods
  # 查看操作记录，前进，后退操作
  include MindmapHistoryRecordsControllerMethods
end
