class SnapshotsController < ApplicationController
  before_filter :per_load
  skip_before_filter :verify_authenticity_token

  def create
    @snapshot = @mindmap.snapshots.new(params[:snapshot])
    if @snapshot.save
      render :json=>{:id=>"snapshot_#{@snapshot.id}",
        :html=>@template.render(:partial=>"snapshots/info_snapshot",
          :locals=>{:snapshot=>@snapshot})
      }
      return
    end
  end

  def recover
    @snapshot.to_recover
    render :partial=>"/mindmaps/list/info_mindmap",:locals=>{:mindmap=>@mindmap,:ul_id=>"mplist_mindmaps"}
  end

  def per_load
    @mindmap = Mindmap.find(params[:mindmap_id]) if params[:mindmap_id]
    @snapshot = Snapshot.find(params[:id]) if params[:id]
  end
end
