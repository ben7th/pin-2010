class ContactsController < ApplicationController
  before_filter :login_required

  def index
  end

  def follow
    if params[:user_id].blank? || params[:channel_ids].blank?
      return render :status=>402,:text=>"参数错误"
    end
    user = User.find(params[:user_id])
    channels = params[:channel_ids].split(",").uniq.
      map{|id|Channel.find_by_id(id)}.compact.
      select{|channel|channel.creator == current_user}
    channels.each{|channel|channel.add_user(user)}
    render :status=>200,:text=>"关注成功"
  end

  def unfollow
    if params[:user_id].blank?
      return render :status=>402,:text=>"参数错误"
    end
    user = User.find(params[:user_id])
    channels = current_user.channels_of_user_db(user)
    channels.each{|channel|channel.remove_user(user)}
    render :status=>200,:text=>"取消关注成功"
  end

end
