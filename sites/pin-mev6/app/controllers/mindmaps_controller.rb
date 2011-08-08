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
    render :partial=>'mindmaps/lists/management',:locals=>{:mindmaps=>[@mindmap]}
  end

  ############### user-auth
  before_filter :login_required,:only=>[:do_clone,:import,:new]

  # 常用关键词
  def aj_words
    @user = User.find_by_id(params[:user_id]) if params[:user_id]
    @user ||= current_user
    render :partial=>'mindmaps/homepage/aj_words',:locals=>{:user=>@user}
  end

  def cooperates
    @mindmaps = current_user.cooperate_mindmaps.paginate(:page=>params[:page]||1,:per_page=>12)
  end

  def comments
    create_feed = false
    create_feed = true if params[:create_feed] == "true"

    mc = current_user.create_comment(@mindmap,params[:content],create_feed)
    if !!mc.id
      redirect_to "/mindmaps/#{@mindmap.id}/info"
    end
  end

  def newest
    file_path = MindmapImageCache.new(@mindmap).thumb_120_img_path
    send_file file_path,:type=>"image/png",:disposition=>'inline'
  end

  def search
    begin
      @query = params[:q]
      @result = MindmapLucene.search_paginate(@query,:page=>params[:page])
    rescue MindmapLucene::MindmapSearchFailureError => ex
      return render_status_page(500,ex)
    end
  end

  def share_original
    MindmapImageCache.new(@mindmap).create_zoom_1_cache_file
    render :status=>200,:text=>"生成图片成功"
  end

  include MindmapImportControllerMethods
  # new import create paramsedit update delete import_base64 create_base64
  include MindmapManagingControllerMethods
  # clone_form do_clone
  include MindmapCloneControllerMethods
  # 查看操作记录，前进，后退操作
  include MindmapHistoryRecordsControllerMethods
end
