class ChannelsController < ApplicationController
  before_filter :login_required,:only=>:none
  
  before_filter :per_load
  def per_load
    @channel = Channel.find(params[:id]) if params[:id] && params[:id] != "none"
  end

  def index
    @user = User.find_by_id(params[:user_id])
  end

  def show
    @current_channel = @channel
    @feeds = @channel.feeds.paginate(:per_page=>20,:page=>params[:page]||1)
  end

  def none
    @current_channel = "none"
    @feeds = current_user.no_channel_feeds.paginate(:per_page=>20,:page=>params[:page]||1)
    set_cellhead_path('index/cellhead')
    return render(:template=>'index/index')
  end

  def create
    channel = Channel.new(:name=>params[:name],:creator_email=>current_user.email)
    if channel.save
      return render :json=>channel.to_json
    end
    render :status=>403, :json=>{:error=>get_flash_error(channel)}
  end

  def destroy
    # 调用Contact类，memcache缓存，在做此操作的时候，会因找不到contact这个类 出错
    Contact
    if @channel.destroy
      return redirect_to "/#{current_user.id}/followings"
    end
  end

  def update
    if @channel.update_attributes(:name=>params[:name])
      return render :status=>200, :text=>"修改成功"
    end
  end

  def add
    ChannelContactOperationQueue.new.add_task(ChannelContactOperationQueue::ADD_OPERATION,@channel.id,params[:user_id])
    return render :status=>200,:text=>"操作完成"
  end

  def remove
    ChannelContactOperationQueue.new.add_task(ChannelContactOperationQueue::REMOVE_OPERATION,@channel.id,params[:user_id])
    return render :status=>200,:text=>"操作完成"
  end

  def fb_orderlist
    render_ui do |ui|
      ui.fbox :show,:title=>'调整频道顺序',:partial=>'channels/fb_orderlist'
    end
  end

  def sort
    ids = params[:ids].split(/,|，/)
    current_user.to_sort_channels_by_ids(ids)
    render :status=>200,:text=>"操作成功"
  end

  # 博客频道发新帖子
  def new_blog_post
    if @channel.kind != Channel::KIND_BLOG || !@channel.is_include_users_or_creator?(current_user)
      redirect_to @channel
      return
    end

    render :template=>'channels/new_templates/new_blog_post.haml'
  end

  def add_users
    users = params[:user_ids].split(",").map do |user_id|
      user = User.find_by_id(user_id)
      user if !@channel.contact_users.include?(user)
    end.compact
    @channel.add_users(users)
    render :partial=>'channels/index_parts/aj_channel_avatars',:locals=>{:users=>users}
  end

end
