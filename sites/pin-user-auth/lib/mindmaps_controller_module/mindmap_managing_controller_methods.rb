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
        return redirect_to pin_url_for("pin-user-auth","users/#{current_user.id}")
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
          redirect_to "/users/#{current_user.id}"
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
    @mindmap = Mindmap.create_by_params(current_user,params[:mindmap])
    return @mindmap
  end

  def _create_mindmap_response_html
    return redirect_to pin_url_for("pin-mev6","/mindmaps/#{@mindmap.id}/edit") if @mindmap
    @mindmap = Mindmap.new
    action = params[:import] ? :import : :new
    set_cellhead_tail action
    error_message = '思维导图参数错误，创建失败'
    error_message = '思维导图标题不能为空' if params[:mindmap][:title].blank?
    flash.now[:error] = error_message
    render :action=> action
  end

  def _create_mindmap_response_json
    if @mindmap
      return render(:json=>"ok")
    end
    render(:json=>"fail",:status=>:unprocessable_entity)
  end

end
