class ContactsController < ApplicationController
  before_filter :login_required

  def index
    @user = User.find(params[:user_id]) if params[:user_id]
  end

  def tsina
  end

  def follow
    if params[:user_id].blank? || params[:channel_ids].blank?
      return render :status=>422,:text=>"参数错误"
    end
    user = User.find(params[:user_id])
    channels = params[:channel_ids].split(",").uniq.
      map{|id|Channel.find_by_id(id)}.compact.
      select{|channel|channel.creator == current_user}
    channels.each{|channel|channel.add_user(user)}
    render :status=>200,:text=>"关注成功"
  end

  def follow_mindpin
    if params[:user_id].blank?
      return render :status=>422,:text=>"参数错误"
    end
    user = User.find(params[:user_id])
    channel = Channel.find_or_create_by_creator_id_and_name(current_user.id,"mindpin社区联系人")
    channel.add_user(user)
    render :status=>200,:text=>"关注成功"
  end

  def follow_by_daotu
    if params[:user_id].blank?
      return render :status=>422,:text=>"参数错误"
    end
    user = User.find(params[:user_id])
    unless current_user.following?(user)
      current_user.daotu_channel.add_user(user)
    end
    render :text=>200,:status=>200
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
