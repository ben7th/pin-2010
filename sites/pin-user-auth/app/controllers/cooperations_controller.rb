class CooperationsController < ApplicationController
  before_filter :pre_load
  def pre_load
    @mindmap = Mindmap.find(params[:mindmap_id])
  end

  def cooperate_dialog
    @cooperate_users = @mindmap.cooperate_users
    @cooperate_edit_email_list_str = @cooperate_users.map{|user|user.email}*","
  end

  def save_cooperations
    cooperate_editors = params[:cooperate_editors].split(/\n|,/)
    cooperate_users = cooperate_editors.map{|email|User.find_by_email(email)}.compact
    # 清空 协同用户
    @mindmap.remove_all_cooperate_users
    # 设置 协同用户
    @mindmap.add_cooperate_users(cooperate_users)
    redirect_to "/mindmaps/#{@mindmap.id}/info"
  end

end
