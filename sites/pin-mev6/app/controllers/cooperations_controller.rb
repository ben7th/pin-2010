class CooperationsController < ApplicationController
  before_filter :pre_load
  def pre_load
    @mindmap = Mindmap.find(params[:mindmap_id])
  end

  before_filter :must_is_creator
  def must_is_creator
    if(@mindmap.user_id != current_user.id)
      return render_status_page(503,'当前用户并非导图作者，不能编辑协同')
    end
  end

  def add_cooperator
    user_ids = params[:user_ids].split(",")
    users = user_ids.map{|id|User.find_by_id(id)}.compact
    @mindmap.add_cooperate_users(users)

    render :partial=>"cooperations/parts/aj_cooperation_avatars",:locals=>{:users=>users}
  end

  def remove_cooperator
    user = User.find_by_id(params[:user_id])
    @mindmap.remove_cooperate_user(user) if !!user
    render :text=>200
  end
end
