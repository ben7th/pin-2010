class V6::EditorController < ApplicationController
  before_filter :per_load
  def per_load
    @mindmap = Mindmap.find(params[:mindmap_id]) if params[:mindmap_id]
  end
  
  layout 'v6'
  
  def index
    if @mindmap.has_edit_rights?(current_user)
      redirect_to :action=>:edit
    else
      redirect_to :action=>:view
    end
  end
  
  def view
    return if @mindmap.has_view_rights?(current_user)
    render_status_page(403,'当前用户对该导图没有查看权限')
  end
  
  def edit
    return if @mindmap.has_edit_rights?(current_user)
    redirect_to :action=>:view
  end
end
