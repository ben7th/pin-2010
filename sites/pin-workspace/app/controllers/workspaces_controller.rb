class WorkspacesController < ApplicationController
  before_filter :login_required,:except=>[:list]
  before_filter :per_load
  def per_load
    @workspace = Workspace.find(params[:id]) if params[:id]
  end

  def index
    @workspaces = current_user.workspaces
    respond_to do |format|
      format.json { render :text=>@workspaces.to_json}
      format.any
    end
  end

  def list
    @workspaces = User.find(params[:req_user_id]).workspaces
    respond_to do |format|
      format.json { render :text=>@workspaces.to_json}
      format.xml { render :text=>@workspaces.to_xml}
    end
  end

  def show;end

  def new
    @workspace = Workspace.new
  end

  def create
    @workspace = Workspace.new(params[:workspace])
    @workspace.user = current_user
    if @workspace.save
      return redirect_to :action=>:index
    end
    render :action=>:new
  end

  def edit
    render_ui.fbox :show,:partial=>[:form,@workspace],:title=>"编辑"
  end

  def update
    if @workspace.update_attributes(params[:workspace])
      render_ui.mplist(:update,@workspace).fbox(:close)
    end
  end

  def destroy
    if @workspace.destroy
      render_ui.mplist :remove,@workspace
    end
  end
end
