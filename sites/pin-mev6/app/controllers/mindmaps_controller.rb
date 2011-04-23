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

  def share
    case params[:site]
    when ConnectUser::TSINA_CONNECT_TYPE
      current_user.share_mindmap_to_tsina_in_queue(@mindmap)
    end
    render_ui.fbox :show,:title=>"分享成功",:partial=>'mindmaps/fbox/share_success',:locals=>{:site=>params[:site]}
  end
  
end
