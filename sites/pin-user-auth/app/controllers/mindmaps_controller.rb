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

  # new import create paramsedit update delete import_base64 create_base64
  include MindmapManagingControllerMethods


  # clone_form do_clone
  include MindmapCloneControllerMethods

  include MindmapRightsHelper

end
