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
