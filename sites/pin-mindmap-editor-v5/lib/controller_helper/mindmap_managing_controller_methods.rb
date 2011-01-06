module MindmapManagingControllerMethods
  def new
    set_tabs_path false
    @mindmap = Mindmap.new
  end

  def import
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

  def paramsedit
    set_tabs_path(false)
    if has_edit_rights?(@mindmap,current_user)
      if request.xhr?
      return render_ui.fbox :show,:title=>"修改导图信息",:partial=>"mindmaps/edit/box_params_edit",:locals=>{:mindmap=>@mindmap}
      end
      return render :template=>"mindmaps/paramsedit"
    end
  end

  def update
    if has_edit_rights?(@mindmap,current_user)
        @mindmap.update_attributes!(params[:mindmap])
        if params[:fbox] == "true"
          responds_to_parent do
            render_ui do |ui|
              ui.mplist(:update,@mindmap,:partial=>"mindmaps/list/info_mindmap").fbox(:close)
            end
          end
          return
        end
        return redirect_to user_mindmaps_path(current_user)
    else
      return render_status_page(403,'当前用户对这个思维导图没有编辑权限')
    end
  end

  # DELETE /mindmaps/1
  def destroy
    respond_to do |format|
      format.html do
        if(@mindmap.user_id == current_user.id)
          @mindmap = Mindmap.find(params[:id])
          @mindmap.destroy
          return render_ui.mplist :remove,@mindmap
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