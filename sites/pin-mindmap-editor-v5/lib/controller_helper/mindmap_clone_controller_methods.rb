module MindmapCloneControllerMethods
  def clone_form
    render_ui.fbox :show,:title=>"复制导图",:partial=>'mindmaps/edit/box_clone',:locals=>{:mindmap=>@mindmap}
  end

  # 克隆
  def do_clone
    clone_m = @mindmap.mindmap_clone(current_user,params[:mindmap])
    redirect_to "/mindmaps/#{clone_m.id}/edit"
  end
end
