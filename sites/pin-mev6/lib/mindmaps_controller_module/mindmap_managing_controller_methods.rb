module MindmapManagingControllerMethods
  def new
    @mindmap = Mindmap.new
  end

  def create
    @mindmap = Mindmap.create_by_params(current_user,params[:mindmap])
    unless @mindmap.id.blank?
      return redirect_to "/mindmaps/#{@mindmap.id}/info?create=successful"
    end
    redirect_to "/mindmaps/new"
  end

  def change_title
    if(@mindmap.user_id != current_user.id)
      return render_status_page(503,'当前用户并非导图作者，不能修改导图标题')
    end

    @mindmap.title = params[:title]
    @mindmap.save_without_timestamping
    render :status=>200,:text=>params[:title]
  end

  # DELETE /mindmaps/1
  def destroy
    @redirect_mindmap = @mindmap.next(current_user)
    @redirect_mindmap = @mindmap.prev(current_user) if @redirect_mindmap.nil?
    if(@mindmap.user_id != current_user.id)
      return render_status_page(503,'当前用户并非导图作者，不能删除导图')
    end
    @mindmap.destroy
    if request.xhr?
      return render_ui.mplist :remove,@mindmap
    end
    respond_to do |format|
      format.html do
        return redirect_to info_mindmap_path(@redirect_mindmap) if !!@redirect_mindmap
        return redirect_to "/mindmaps/users/#{current_user.id}"
      end
      format.xml do
        head :ok
      end
    end
  end


  def info
    if !has_view_rights?(@mindmap,current_user)
      return render_status_page(403,'当前用户对这个思维导图没有编辑权限')
    end
  end

  def toggle_private
    if(@mindmap.user_id != current_user.id)
      return render :status=>503,:text=>"修改失败"
    end

    if @mindmap.toggle_private
      return render :partial=>'mindmaps/lists/management',:locals=>{:mindmaps=>[@mindmap]}
    end
    return render :status=>503,:text=>"修改失败"
  end

  def public_maps
    @mindmaps = Mindmap.publics.paginate({:order=>"id desc",:page=>params[:page],:per_page=>25})
  end

  def user_mindmaps
    @user = User.find(params[:user_id])
    if @user == current_user
      redirect_to '/mindmaps'
    end
    
    @mindmaps = @user.out_mindmaps_paginate(:page=>params[:page]||1,:per_page=>12)
    @current_channel = 'mindmaps'
  end

  def mine_private
    @mindmaps = current_user.private_mindmaps_paginate(:page=>params[:page]||1,:per_page=>12)
  end

end
