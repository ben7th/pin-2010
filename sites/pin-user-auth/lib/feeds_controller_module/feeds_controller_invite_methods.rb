module FeedsControllerInviteMethods
  def invite
    users = params[:user_ids].split(",").uniq.map{|id|User.find_by_id(id)}.compact
    return render :text=>"不能邀请自己",:status=>503 if users.include?(current_user)
    return render :text=>"不能邀请主题的创建者",:status=>503 if users.include?(@feed.creator)
    @feed.invite_users(users,current_user)
    render :partial=>'feeds/show_parts/invite_users',:locals=>{:feed=>@feed}
  end

  def cancel_invite
    user = User.find_by_id(params[:user_id])
    @feed.cancel_invite_user(user)
    render :text=>200
  end

  def send_invite_email
    @feed.send_invite_email(current_user,params[:email],params[:title],params[:postscript])
    render :text=>200
  end
end
