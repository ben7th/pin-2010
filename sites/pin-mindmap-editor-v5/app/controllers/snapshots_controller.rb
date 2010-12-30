class SnapshotsController < ApplicationController
  before_filter :per_load
  def per_load
    @mindmap = Mindmap.find(params[:mindmap_id]) if params[:mindmap_id]
  end

  def new
    render_ui.fbox :show,:title=>"创建导图快照",:partial=>"snapshots/snapshot_form",:locals=>{:mindmap=>@mindmap}
  end

  def create
    begin
      @mindmap.create_snapshot(params[:snapshot][:message])
      render_ui do |ui|
        ui.page << "alert('导图的快照创建成功')"
      end
    rescue MindmapSnapshotMethods::CreateSnapshotError => ex
      render :text=>"创建快照失败",:status=>500
    rescue MindmapSnapshotMethods::CreateSnapshotNoContentChangeError => ex
      render :text=>"导图内容没有变化，不能保存快照",:status=>500
    end
  end

  def recover
    begin
      @mindmap.recover_snapshot(params[:id])
      redirect_to edit_mindmap_url(@mindmap)
    rescue MindmapSnapshotMethods::RecoverSnapshotError => ex
      render :text=>"恢复快照失败，出现错误",:status=>500
    end
  end

end
