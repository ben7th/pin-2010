module MindmapImportControllerMethods
  def self.included(base)
    base.skip_before_filter :verify_authenticity_token,:only=>[:upload_import_file]
  end

  def import
    @mindmap = Mindmap.new
  end

  def upload_import_file
    upload_temp_id = MindmapImportAdpater.create_by_upload_file(params[:file], params[:Filename])
    url            = MindmapImportAdpater.thumb_url_by_upload_temp_id(upload_temp_id)
    type           = MindmapImportAdpater.file_type_by_filename(params[:Filename])
    nodes_count    = MindmapImportAdpater.nodes_count_by_upload_temp_id(upload_temp_id)
    filename       = MindmapImportAdpater.title_by_filename(params[:Filename])


        struct = MindmapImportAdpater.struct_by_upload_temp_id(upload_temp_id)


    render :json=>{
      :upload_temp_id => upload_temp_id,
      :thumb_src      => url,
      :type           => type,
      :nodes_count    => nodes_count,
      :filename       => filename
    }
  rescue Exception => ex
    case ex
    when MindmapImportAdpater::UnSupportFormatError
      render :status=>510, :text=>"不支持的导图格式"
    when MindmapImportAdpater::StructError
      render :status=>511, :text=>"解析文件出错"
    when MindmapImportAdpater::CreateThumbError
      render :status=>512, :text=>"导图缩略图生成失败"
    end
  end

  def import_file_thumb
    thumb_path = MindmapImportAdpater.thumb_file_path_by_upload_temp_id(params[:upload_temp_id])
    send_file thumb_path,:type=>"image/png",:disposition=>'inline'
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
