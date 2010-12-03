module MindmapParamsEditingMethods
  def new
    set_tabs_path false
    @mindmap = Mindmap.new
  end

  def create
    @mindmap = _create_mindmap

    respond_to do |format|
      format.html { return _create_mindmap_response_html }
      format.json { return _create_mindmap_response_json }
    end
  end

  def create_base64
    attr = {:title=>params[:title],:private=>params[:is_private]}
    if params[:logo_base64]
      # jpg 等类型的图片文件
      file = File.open("/tmp/mindmaps_logo_base64_#{randstr}","w") do |f|
        f << decode64(params[:logo_base64])
      end
      attr[:logo] = File.open(file.path,"r")
    end
    @mindmap = Mindmap.create_by_params(current_user,attr)
    if @mindmap
      render :json=>mindmap_json(@mindmap)
    end
  end

  def import_base64
    # mmap,等导图文件类型
    file = File.open("/tmp/mindmaps_base64_#{randstr}.#{params[:type]}","w") do |f|
      f << decode64(params[:import_file_base64])
    end
    attr = {:import_file=>File.open(file.path,"r"),:title=>params[:title]}
    @mindmap = Mindmap.create_by_params(current_user,attr)
    if @mindmap
      render :json=>mindmap_json(@mindmap)
    end
  end

  def _create_mindmap
    @mindmap = Mindmap.create_by_params(current_user,params[:mindmap])
    if @mindmap && !current_user
      add_nobody_mindmap_to_cookies(@mindmap)
    end
    return @mindmap
  end

  def _create_mindmap_response_html
    return redirect_to edit_mindmap_path(@mindmap) if @mindmap   
    @mindmap = Mindmap.new
    action = params[:import] ? :import : :new
    set_cellhead_tail action
    flash.now[:error] = '思维导图参数错误，创建失败'
    render :action=> action
  end

  def _create_mindmap_response_json
    if @mindmap
      return render(:json=>"ok")
    end
    render(:json=>"fail",:status=>:unprocessable_entity)
  end

end
