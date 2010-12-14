module MindmapCloneMethods
  def clone_form
    @mindmap = Mindmap.find(params[:id])
    render_ui.fbox :show,:title=>"克隆导图",:partial=>'mindmaps/edit/box_clone',:locals=>{:mindmap=>@mindmap}
  end

  # 克隆
  def clone
    @mindmap = Mindmap.find(params[:id])
    clone_m = @mindmap.mindmap_clone(current_user,params[:mindmap])
    render_ui.mplist(:insert,[current_user,clone_m],:partial=>"mindmaps/list/info_mindmap",:locals=>{:mindmap=>clone_m},:prev=>"TOP").fbox(:close)
  end
end
