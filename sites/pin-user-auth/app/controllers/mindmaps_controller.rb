class MindmapsController < ApplicationController
  before_filter :per_load
  before_filter :login_required,:only=>[:do_clone]
  def per_load
    @mindmap = Mindmap.find(params[:id]) if params[:id]
  end

  # 常用关键词
  def aj_words
    render :partial=>'index/homepage/aj_words',:locals=>{:user=>current_user}
  end

  def cooperates
    @mindmaps = current_user.cooperate_mindmaps
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

  # new import create paramsedit update delete import_base64 create_base64
  include MindmapManagingControllerMethods


  # clone_form do_clone
  include MindmapCloneControllerMethods

  include MindmapRightsHelper

end
