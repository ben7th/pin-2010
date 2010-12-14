class CooperationsController < ApplicationController
  before_filter :pre_load
  def pre_load
    @mindmap = Mindmap.find(params[:mindmap_id])
  end

  def cooperate_dialog
    render_ui.fbox :show,:title=>"导图协同",:partial=>'cooperations/cooperate_dialog',:locals=>{:mindmap=>@mindmap}
  end

  def save_cooperations
    cooperate_viewers = params[:cooperate_viewers].split(/\n|;/)
    cooperate_editors = params[:cooperate_editors].split(/\n|;/)

    # 清空 协同编辑
    @mindmap.cooperate_editors.each { |user| @mindmap.remove_cooperate_editor(user) }
    # 清空 协同查看
    @mindmap.cooperate_viewers.each { |user| @mindmap.remove_cooperate_viewer(user) }
    # 设置 协同编辑
    cooperate_editors.each{|email| @mindmap.add_cooperate_editor(email)}
    # 设置 协同查看
    cooperate_viewers.each{|email| @mindmap.add_cooperate_viewer(email)}
    render_ui.fbox :close
  end

end
