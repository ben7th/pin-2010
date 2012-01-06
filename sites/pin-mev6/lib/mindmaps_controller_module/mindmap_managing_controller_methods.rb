module MindmapManagingControllerMethods
  # DELETE /mindmaps/1
  def destroy
    if(@mindmap.user_id != current_user.id)
      return render_status_page(503,'当前用户并非导图作者，不能删除导图')
    end
    @mindmap.destroy
    render :text=>'ok'
  end


  def info
    if !has_view_rights?(@mindmap,current_user)
      return render_status_page(403,'当前用户对这个思维导图没有查看权限')
    end
  end

  # 切换公开私有
  def toggle_private
    if(@mindmap.user_id != current_user.id)
      return render :status=>401, :text=>"没有编辑权限"
    end

    if @mindmap.toggle_private
      return render :text=>@mindmap.private?
    end

    return render :status=>503,:text=>"修改失败"
  rescue
    return render :status=>503,:text=>"修改失败"
  end

end
