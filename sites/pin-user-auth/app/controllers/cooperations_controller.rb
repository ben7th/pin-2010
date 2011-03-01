class CooperationsController < ApplicationController
  before_filter :pre_load
  def pre_load
    @mindmap = Mindmap.find(params[:mindmap_id])
  end

  def cooperate_dialog
    @cooperate_edit_email_list_str = @mindmap.cooperate_edit_email_list*","
    @cooperate_view_email_list_str = @mindmap.cooperate_view_email_list*","
  end

  def save_cooperations
    cooperate_viewers = params[:cooperate_viewers].split(/\n|,/)
    cooperate_editors = params[:cooperate_editors].split(/\n|,/)
    # 清空 协同编辑
    @mindmap.remove_all_cooperate_editor
    # 清空 协同查看
    @mindmap.remove_all_cooperate_viewer
    # 设置 协同编辑
    cooperate_editors.each{|email| @mindmap.add_cooperate_editor(email)}
    # 设置 协同查看
    cooperate_viewers.each{|email| @mindmap.add_cooperate_viewer(email)}
    redirect_to "/mindmaps/#{@mindmap.id}/info"
  end

end
