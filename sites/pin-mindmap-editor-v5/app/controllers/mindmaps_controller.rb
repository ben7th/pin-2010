class MindmapsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :per_load
  def per_load
    @mindmap = Mindmap.find(params[:id]) if params[:id]
  end

  # 查找相关方法，主要用于index
  include MindmapFindingControllerMethods

  # new import create paramsedit update delete import_base64 create_base64
  include MindmapManagingControllerMethods


  # clone_form do_clone
  include MindmapCloneControllerMethods
  
  def index
    @mindmaps = get_all_public_mindmaps
    @mapdata = get_public_mapdata
  end

end
