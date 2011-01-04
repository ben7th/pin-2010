class FilesController < ApplicationController
  before_filter :per_load
  def per_load
    @mindmap = Mindmap.find(params[:mindmap_id]) if params[:mindmap_id]
  end

  def index
    render :partial=>"/files/mindmap_image_page",:locals=>{:mindmap=>@mindmap,:page=>params[:page]}
  end

  # 上传文件
  def upload_file
    begin
      filename = @mindmap.upload_file_to_repo(params[:file])
      render :partial=>"/files/mindmap_image_thumb",:locals=>{:mindmap=>@mindmap,:filename=>filename}
    rescue MindmapImageMethods::UploadError => ex
      render_ui do |ui|
        ui.page << "alert('上传文件失败')"
      end
    end
  end

  # 复制网络文件
  def upload_web_file
    begin
      file_name = @mindmap.upload_web_file_to_repo(params[:url])
      url = mindmap_show_upload_file_url(:id=>@mindmap.id,:path=>file_name)
      render :text=>url
    rescue MindmapImageMethods::UploadError => ex
      render :text=>"复制网络资源失败",:status=>500
    end

  end

  # 显示图片
  def show_upload_file
    file_name = params[:path].first
    file_path = @mindmap.upload_file_absolute_path(file_name)
    _send_image file_path
  end

  # 显示图片缩略
  def show_upload_file_thumb
    file_name = params[:path].first
    file_path = @mindmap.upload_file_absolute_path(file_name)
    thumb_path = ImgResize.new(file_path).dump_max_of(90,60)
    _send_image thumb_path
  end

  # 搜索google图片
  def search_image
    json = GoogleSearch.new(params[:query]).images.map do |image|
      {:uri=>image.uri,:height=>image.height,:width=>image.width,:thumbnail_uri=>image.thumbnail_uri,:thumbnail_height=>image.thumbnail_height,:thumbnail_width=>image.thumbnail_width,:content=>image.content}
    end.to_json
    render :json=>json
  end

  # 删除图片
  def destroy
    file_name = params[:path]
    if @mindmap.delete_file(file_name)
      return render :status=>200,:text=>"删除成功"
    end
  rescue MindmapImageMethods::DeleteUploadedImageError => ex
    render :text=>"文件删除失败",:status=>500
  end

  def show_image_editor
    render_ui do |ui|
      ui.fbox(:show,
        :title   => "导图编辑 - 图片引用",
        :partial => "mindmaps/editor_page/module/image_editor",
        :locals  => {:mindmap=>@mindmap})
      ui.page << 'mindmap._node_image_editor._rails_controller_callback()'
    end
  end

  private
  def _send_image(image_file_path)
    file_name = File.basename(image_file_path)
    send_file image_file_path, :filename=>file_name, :disposition=>'inline', :type=>mime_type(file_name)
  end

  def mime_type(file_name)
    guesses = MIME::Types.type_for(file_name) rescue []
    guesses.first ? guesses.first.simplified : "text/plain"
  end
  
end