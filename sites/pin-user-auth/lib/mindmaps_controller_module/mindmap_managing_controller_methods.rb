module MindmapManagingControllerMethods
  def new
    set_tabs_path false
    @mindmap = Mindmap.new
  end

  def import
    render_ui.fbox :show,:title=>"导入导图",:partial=>'mindmaps/fbox/import'
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
    @redirect_mindmap = @mindmap.next
    @redirect_mindmap = @mindmap.prev if @redirect_mindmap.nil?
    respond_to do |format|
      format.html do
        if(@mindmap.user_id == current_user.id)
          @mindmap = Mindmap.find(params[:id])
          @mindmap.destroy
          return redirect_to info_mindmap_path(@redirect_mindmap) if !!@redirect_mindmap
          return redirect_to "users/#{current_user.id}"
          #          return render_ui.mplist :remove,@mindmap
        else
          return render_status_page(403,'当前用户并非导图作者，不能删除导图')
        end
      end
      format.xml do
        @mindmap.destroy
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

end
