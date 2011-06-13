class ViewpointRevisionsController < ApplicationController
  before_filter :pre_load
  def pre_load
    @viewpoint = Viewpoint.find(params[:viewpoint_id]) if params[:viewpoint_id]
    @viewpoint_revision = ViewpointRevision.find(params[:id]) if params[:id]
  end

  def index
  end

  def show
  end

  def rollback
    @viewpoint_revision = ViewpointRevision.find(params[:id])
    @viewpoint_revision.rollback(current_user)
    render :text=>200
  end
end
