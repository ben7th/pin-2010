module MindmapFileUploadControllerMethods
  def upload_file
    responds_to_parent do
      @mindmap = Mindmap.find(params[:id])
      begin
        file_name = @mindmap.upload_file_to_repo(params[:file])
        url = mindmap_show_upload_file_url(:id=>@mindmap.id,:path=>file_name)
        render_ui do |ui|
          ui.page << "update_node_image(#{url.to_json})"
        end
      rescue MindmapNoteMethods::UploadError => ex
        render_ui do |ui|
          ui.page << "alert('上传文件失败')"
        end
#        render :text=>"上传文件失败",:status=>500
      end

    end
  end

  def upload_web_file
    @mindmap = Mindmap.find(params[:id])
    begin
      file_name = @mindmap.upload_web_file_to_repo(params[:url])
      url = mindmap_show_upload_file_url(:id=>@mindmap.id,:path=>file_name)
      render :text=>url
    rescue MindmapNoteMethods::UploadError => ex
      render :text=>"复制网络资源失败",:status=>500
    end

  end

  def show_upload_file
    @mindmap = Mindmap.find(params[:id])
    file_name = params[:path].first
    file_path = @mindmap.upload_file_absolute_path(file_name)
    send_image file_path
  end

  def show_upload_file_thumb
    @mindmap = Mindmap.find(params[:id])
    file_name = params[:path].first
    file_path = @mindmap.upload_file_absolute_path(file_name)
    thumb_path = ImgResize.new(file_path).dump_max_of(90,50)
    send_image thumb_path
  end

  def send_image(image_file_path)
    file_name = File.basename(image_file_path)
    send_file image_file_path, :filename=>file_name, :disposition=>'inline', :type=>mime_type(file_name)
  end
end
