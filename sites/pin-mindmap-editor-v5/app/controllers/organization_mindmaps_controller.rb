class OrganizationMindmapsController < ApplicationController

  include MindmapParamsEditingMethods

  before_filter :login_required
  before_filter :per_load
  def per_load
    @organization = Organization.find(params[:organization_id]) if params[:organization_id]
  end

  def new
    set_tabs_path false
    @mindmap = Mindmap.new
  end

  def import
    @mindmap = Mindmap.new
    set_tabs_path false
  end

  def create
    @mindmap = _create_mindmap

    @mindmap.add_cooperate_editor(@organization.logic_email) if @mindmap
    
    respond_to do |format|
      format.html { return _create_mindmap_response_html }
      format.json { return _create_mindmap_response_json }
    end
  end

end
