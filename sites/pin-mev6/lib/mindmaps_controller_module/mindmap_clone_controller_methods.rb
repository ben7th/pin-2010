module MindmapCloneControllerMethods
  def clone_form
    if logged_in?
      render_ui.fbox :show,:title=>"复制导图",:partial=>'mindmaps/parts/box_clone',:locals=>{:mindmap=>@mindmap}
      return
    end
    render_ui.fbox :show,'您目前没有登录，请登录后再复制导图'
  end

  # 克隆
  def do_clone
    clone_m = @mindmap.mindmap_clone(current_user,params[:mindmap])
    redirect_to "/mindmaps/#{clone_m.id}/edit"
  end
end
