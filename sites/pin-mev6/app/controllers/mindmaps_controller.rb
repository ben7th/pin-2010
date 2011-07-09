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

  ############### user-auth
  before_filter :login_required,:only=>[:do_clone]

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

  include MindmapImportControllerMethods
  # new import create paramsedit update delete import_base64 create_base64
  include MindmapManagingControllerMethods
  # clone_form do_clone
  include MindmapCloneControllerMethods

end
