class MindmapsController < ApplicationController
  before_filter :per_load
  def per_load
    @mindmap = Mindmap.find(params[:id]) if params[:id]
  end

  # new import create paramsedit update delete import_base64 create_base64
  include MindmapManagingControllerMethods


  # clone_form do_clone
  include MindmapCloneControllerMethods

  include MindmapRightsHelper
end
