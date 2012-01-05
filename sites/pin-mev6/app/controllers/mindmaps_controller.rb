class MindmapsController < ApplicationController
  include MindmapRightsHelper
  include MindmapEditorControllerMethods
  before_filter :per_load
  def per_load
    @mindmap = Mindmap.find(params[:id]) if params[:id]
  end

  def favs
    @mindmaps = current_user.fav_mindmaps_paginate(:page=>params[:page]||1,:per_page=>20)
  end

  def toggle_fav
    current_user.toggle_fav_mindmap(@mindmap)
    render :text=>@mindmap.faved_by?(current_user)
  rescue
    render :status=>503, :text=>'操作失败'
  end

  ############### user-auth
  before_filter :login_required,:only=>[:do_clone,:import,:new]

  def cooperates
    @mindmaps = current_user.cooperate_mindmaps.paginate(:page=>params[:page]||1,:per_page=>12)
  end

  def search
    begin
      @query = params[:q]
      @result = MindmapLucene.search_paginate(@query,:page=>params[:page],:per_page=>12)
    rescue MindmapLucene::MindmapSearchFailureError => ex
      return render_status_page(500,ex)
    end
  end

  def refresh_thumb
    MindmapImageCache.new(@mindmap).refresh_all_cache_file

    size_param = params[:size_param] || "500x500"
    render :text=>@mindmap.thumb_image_url(size_param)
  end

  include MindmapImportControllerMethods
  # new import create paramsedit update delete import_base64 create_base64
  include MindmapManagingControllerMethods
  # 查看操作记录，前进，后退操作
  include MindmapHistoryRecordsControllerMethods
end
