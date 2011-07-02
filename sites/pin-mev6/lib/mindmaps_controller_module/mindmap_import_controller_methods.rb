module MindmapImportControllerMethods
  def upload_import_file
    randstr_id = MindmapImportAdpater.create_by_upload_file(params[:file],params[:file_name])
    render :text=>randstr_id
  end

  def import_file_thumb
    thumb_path = MindmapImportAdpater.thumb_by_randstr_id(params[:randstr])
    send_file thumb_path,:type=>"image/png",:disposition=>'inline'
  end

  def do_import
    struct = MindmapImportAdpater.struct_by_randstr_id(params[:randstr])
  end
end
