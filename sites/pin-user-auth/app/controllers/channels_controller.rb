class ChannelsController < ApplicationController
  before_filter :login_required,:only=>:none
  
  before_filter :per_load
  def per_load
    @channel = Channel.find(params[:id]) if params[:id] && params[:id] != "none"
  end

  def show
    @current_channel = @channel
    @feeds = @channel.in_feeds.paginate(:per_page=>20,:page=>params[:page]||1)
  end

  def create
    channel = Channel.new(:name=>params[:name],:creator=>current_user)
    if channel.save
      return render :partial=>'contacts/parts/channel_set_info',:locals=>{:channel=>channel}
    end
    render :status=>403, :json=>{:error=>get_flash_error(channel)}
  end

  def destroy
    @channel.destroy
    if request.xhr?
      render :status=>200,:text=>"删除成功"
    else
      redirect_to "/contacts"
    end
  end

  def edit
  end

  def update
    if @channel.update_attributes(:name=>params[:name])
      return render :status=>200, :text=>"修改成功"
    end
  end

  def add
    user = User.find(params[:user_id])
    @channel.add_user(user)
    return render :status=>200,:text=>"操作完成"
  end

  def remove
    user = User.find(params[:user_id])
    channels = @channel.remove_user(user)
    ids = channels.map{|channel|channel.id}
    render :json=>ids
  end

  def add_users
    users = params[:user_ids].split(",").map do |user_id|
      User.find_by_id(user_id)
    end.compact
    @channel.add_users(users)
    render :partial=>'contacts/parts/channel_set_info',:locals=>{:channel=>@channel}
  end

end
