class ChannelsController < ApplicationController
  before_filter :login_required,:only=>:none
  
  before_filter :per_load
  def per_load
    @channel = Channel.find(params[:id]) if params[:id] && params[:id] != "none"
  end

  def index
    @channels = Channel.all.paginate(:per_page=>20,:page=>params[:page]||1)
  end

  def user_index
    @user = User.find(params[:user_id])
  end

  def show
    @current_channel = @channel
    @feeds = @channel.in_feeds.paginate(:per_page=>20,:page=>params[:page]||1)
  end

  def none
    @current_channel = "none"
    @feeds = current_user.no_channel_feeds.paginate(:per_page=>20,:page=>params[:page]||1)
    set_cellhead_path('index/cellhead')
    return render(:template=>'index/index')
  end

  def create
    channel = Channel.new(:name=>params[:name],:creator=>current_user)
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
      User.find_by_id(user_id)
    end.compact
    @channel.add_users(users)
    render :partial=>'contacts/parts/channel_set_info',:locals=>{:channel=>@channel}
  end

  def newest_feed_ids
    newest_feeds_ids = ChannelUserFeedProxy.new(current_user,@channel).newest_feeds_ids
    render :status=>200,:json=>{:newest_feeds_ids_count=>newest_feeds_ids.size}.to_json
  end

end
