class BuilderController < ApplicationController
  before_filter :login_required,:only=>[:import,:new,:cooperates]
  
  def new
  end
  
  def import
    @mindmap = Mindmap.new
  end
  
  def import_upload
    logger.debug("current_user #{current_user.id}")
    logger.debug(params[:file].original_filename)
    
    adpater = MindmapImportAdpater.new(current_user)
    adpater.import(params[:file])
    
    render :json=>{
      :type           => adpater.file_type,
      :nodes_count    => adpater.nodes_count,
      :filename       => adpater.title
    }
  rescue MindmapImportAdpater::UnSupportFormatError
    render :status=>510, :text=>"不支持的导图格式"
  rescue MindmapImportAdpater::StructError
    render :status=>511, :text=>"解析文件出错"
  rescue MindmapImportAdpater::CreateThumbError
    render :status=>512, :text=>"导图缩略图生成失败"
  end
  
  def create
    mindmap = Mindmap.new(params[:mindmap])
    mindmap.user = current_user
    MindmapDocument.new(mindmap).init_default_struct
    if mindmap.save
      return redirect_to "/mindmaps/#{mindmap.id}/info"
    end
    redirect_to '/new'
  end
  
  def do_import
    struct = MindmapImportAdpater.struct_by_upload_temp_id(params[:upload_temp_id])
    original_file_path = MindmapImportAdpater.original_file_path_by_upload_temp_id(params[:upload_temp_id])
    mindmap = Mindmap.import(current_user,params[:mindmap],struct,original_file_path)
    MindmapImportAdpater.remove_file_by_upload_temp_id(params[:upload_temp_id])
    
    if mindmap.id.blank?
      return redirect_to :action=>:import
    end
    redirect_to "/mindmaps/#{mindmap.id}/info"
  end
end
