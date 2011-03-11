module MindmapManagingControllerMethods
  def new
    set_tabs_path false
    @mindmap = Mindmap.new
  end

  def import_file
    qid = ImportMindmapQueue.new.add_task(params[:Filename],params[:file],current_user)
    # ImportMindmapQueue.import_success?(qid)
    render :json=>{:qid=>qid}.to_json
  end

  def create
    @mindmap = _create_mindmap

    respond_to do |format|
      format.html { return _create_mindmap_response_html }
      format.json { return _create_mindmap_response_json }
    end
  end

  def change_title
    if has_edit_rights?(@mindmap,current_user)
      @mindmap.title = params[:title]
      @mindmap.save_without_timestamping
      render :status=>200,:text=>params[:title]
    else
      return render_status_page(403,'当前用户对这个思维导图没有编辑权限')
    end
  end

  # DELETE /mindmaps/1
  def destroy
    @redirect_mindmap = @mindmap.next(current_user)
    @redirect_mindmap = @mindmap.prev(current_user) if @redirect_mindmap.nil?
    if(@mindmap.user_id != current_user.id)
      return render_status_page(403,'当前用户并非导图作者，不能删除导图')
    end
    @mindmap.destroy
    if request.xhr?
      return render_ui.mplist :remove,@mindmap
    end
    respond_to do |format|
      format.html do
        return redirect_to info_mindmap_path(@redirect_mindmap) if !!@redirect_mindmap
        return redirect_to "users/#{current_user.id}"
      end
      format.xml do
        head :ok
      end
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
    @mindmap = Mindmap.create_by_title(current_user,params[:content])
    return @mindmap
  end

  def _create_mindmap_response_html
    return redirect_to pin_url_for("pin-mev6","/mindmaps/#{@mindmap.id}/edit") if @mindmap
    render :status=>:unprocessable_entity
  end

  def _create_mindmap_response_json
    if @mindmap
      return render(:json=>"ok")
    end
    render(:json=>"fail",:status=>:unprocessable_entity)
  end

  def info
    set_cellhead_path('/index/cellhead')
    if !has_view_rights?(@mindmap,current_user)
      return render_status_page(403,'当前用户对这个思维导图没有编辑权限')
    end
  end

  def do_private
    if has_edit_rights?(@mindmap,current_user)
      @mindmap.private = @mindmap.private? ? false : true
      if @mindmap.save_without_timestamping
        return render :status=>200,:text=>"修改成功"
      end
    end
    return render :status=>500,:text=>"修改失败"
  end

  def public_maps
    set_cellhead_path('/index/cellhead')
    @mindmaps = Mindmap.publics.valueable.paginate({:order=>"id desc",:page=>params[:page],:per_page=>25})
  end

  def index
    channel_param = params[:channel]
    
    if channel_param.blank?
      @mindmaps = current_user.mindmaps.paginate(:page=>params[:page]||1,:per_page=>21)
      return
    end

    if channel_param == "none"
      @current_channel = "none"
      @mindmaps = Mindmap.no_channel_mindmaps_of(current_user).paginate(:page=>params[:page]||1,:per_page=>21)
      return
    end
    
    channel = Channel.find_by_id(channel_param)
    @current_channel = channel
    @mindmaps = Mindmap.channel_mindmaps(channel).paginate(:page=>params[:page]||1,:per_page=>21)
  end
  
end
