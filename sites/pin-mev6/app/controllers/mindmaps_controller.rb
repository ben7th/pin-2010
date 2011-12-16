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

  # 常用关键词
  def aj_words
    @user = User.find_by_id(params[:user_id]) if params[:user_id]
    @user ||= current_user
    render :partial=>'mindmaps/homepage/aj_words',:locals=>{:user=>@user}
  end

  def cooperates
    @mindmaps = current_user.cooperate_mindmaps.paginate(:page=>params[:page]||1,:per_page=>12)
  end

  def newest
    file_path = MindmapImageCache.new(@mindmap).thumb_120_img_path
    send_file file_path,:type=>"image/png",:disposition=>'inline'
  end

  def search
    begin
      @query = params[:q]
      @result = MindmapLucene.search_paginate(@query,:page=>params[:page],:per_page=>12)
    rescue MindmapLucene::MindmapSearchFailureError => ex
      return render_status_page(500,ex)
    end
  end

  def share_original
    image_path = MindmapImageCache.new(@mindmap).create_zoom_1_cache_file
    current_user.send_tsina_image_status(image_path,params[:content])
    render :status=>200,:text=>"生成图片成功"
  rescue Tsina::RepeatSendError => ex
    render :status=>500,:json=>{:code=>3,:message=>ex.message}
  rescue Tsina::ContentLengthError => ex
    render :status=>500,:json=>{:code=>2,:message=>ex.message}
  rescue Tsina::OauthFailureError => ex
    render :status=>500,:json=>{:code=>1,:message=>ex.message}
  rescue Exception => ex
    render :status=>500,:json=>{:code=>0,:message=>ex.message}
  end

  def refresh_thumb
    MindmapImageCache.new(@mindmap).refresh_all_cache_file

    size_param = params[:size_param] || "500x500"
    render :text=>@mindmap.thumb_image_url(size_param)
  end

  include MindmapImportControllerMethods
  # new import create paramsedit update delete import_base64 create_base64
  include MindmapManagingControllerMethods
  # clone_form do_clone
  include MindmapCloneControllerMethods
  # 查看操作记录，前进，后退操作
  include MindmapHistoryRecordsControllerMethods
end
