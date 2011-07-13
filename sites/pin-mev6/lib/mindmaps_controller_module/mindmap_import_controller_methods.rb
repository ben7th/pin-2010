module MindmapImportControllerMethods
  def import
    @mindmap = Mindmap.new
  end

  def upload_import_file
    upload_temp_id = MindmapImportAdpater.create_by_upload_file(params[:file],params[:Filename])
    url = MindmapImportAdpater.thumb_url_by_upload_temp_id(upload_temp_id)
    type = MindmapImportAdpater.file_type_by_filename(params[:Filename])
    nodes_count = MindmapImportAdpater.nodes_count_by_upload_temp_id(upload_temp_id)
    filename = MindmapImportAdpater.title_by_filename(params[:Filename])


        struct = MindmapImportAdpater.struct_by_upload_temp_id(upload_temp_id)
    mup_ap struct

    render :json=>{:upload_temp_id=>upload_temp_id,:thumb_src=>url,
      :type=>type,:nodes_count=>nodes_count,:filename=>filename}
  end

  def import_file_thumb
    thumb_path = MindmapImportAdpater.thumb_file_path_by_upload_temp_id(params[:upload_temp_id])
    send_file thumb_path,:type=>"image/png",:disposition=>'inline'
  end

  def do_import
    struct = MindmapImportAdpater.struct_by_upload_temp_id(params[:upload_temp_id])
    mup_ap struct
    mindmap = Mindmap.import(current_user,params[:mindmap],struct)
    MindmapImportAdpater.remove_file_by_upload_temp_id(params[:upload_temp_id])
    
    if mindmap.id.blank?
      return redirect_to :action=>:import
    end
    redirect_to "/mindmaps/#{mindmap.id}/info"
  end
end