class MindmapsController < ApplicationController
  before_filter :per_load
  before_filter :login_required,:only=>[:do_clone]
  def per_load
    @mindmap = Mindmap.find(params[:id]) if params[:id]
  end

  # 常用关键词
  def aj_words
    @user = User.find_by_id(params[:user_id]) if params[:user_id]
    @user ||= current_user
    render :partial=>'mindmaps/homepage/aj_words',:locals=>{:user=>@user}
  end

  def cooperates
    @mindmaps = current_user.cooperate_mindmaps.paginate(:page=>params[:page]||1,:per_page=>12)
  end

  def share
    case params[:site]
    when ConnectUser::TSINA_CONNECT_TYPE
      current_user.share_mindmap_to_tsina_in_queue(@mindmap)
    end
    render_ui.fbox :show,:title=>"分享成功",:partial=>'mindmaps/fbox/share_success',:locals=>{:site=>params[:site]}
  end

  def fav
    current_user.add_fav_mindmap(@mindmap)
    render :text=>"操作成功"
  end

  def unfav
    current_user.remove_fav_mindmap(@mindmap)
    render :text=>"操作成功"
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
    file_path = MindmapImageCache.new(@mindmap).get_img_path_by("120x120")
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

  # new import create paramsedit update delete import_base64 create_base64
  include MindmapManagingControllerMethods


  # clone_form do_clone
  include MindmapCloneControllerMethods

  include MindmapRightsHelper

end
