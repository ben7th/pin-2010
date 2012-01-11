module V6
  class EditorController < ApplicationController
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
    
    def save
      mindmap = Mindmap.find(params[:map])
      opers = ActiveSupport::JSON.decode(params[:operations])
      revision = ActiveSupport::JSON.decode(params[:revision])
      local_revision = revision["local"].to_i
      
      if !mindmap.has_edit_rights?(current_user)
        return render :xml=>{:code=>MindmapOperate::ErrorCode::ACCESS_NOT_VALID},:status=>403
      end
      
      if mindmap.revision != local_revision
        return render :xml=>{:code=>MindmapOperate::ErrorCode::REVISION_NOT_VALID},:status=>422
      end
      
      begin
        opers.each do |oper|
          MindmapOperate.new(mindmap,oper,current_user).do_operation
        end
        return render :json=>{:revision=>mindmap.revision}
      rescue MindmapOperate::NodeNotExistError
        return render :json=>{:code=>MindmapOperate::ErrorCode::NODE_NOT_EXIST},:status=>500
      rescue MindmapOperate::MindmapNotSaveError
        return render :json=>{:code=>MindmapOperate::ErrorCode::MINDMAP_NOT_SAVE},:status=>500
      rescue Exception => ex
        puts ex.message
        puts ex.backtrace*"\n"
        return render :json=>{:code=>MindmapOperate::ErrorCode::UNKNOWN},:status=>500
      end
    end
  end
end