class RollingController <  ApplicationController
  before_filter :get_majia_user

  def get_majia_user
    if Rails.env.production?
      return render_status_page(403,'必须指定用户登陆后才能操作') if !logged_in?
      return render_status_page(403,'只有指定用户才能操作') if ![1002,1018,1012851,1001,1017].include? current_user.id
    end


    majia_ids = case Rails.env
    when 'development'
      (1000001..1000029).to_a + [1000035,1000036,1000039,1000040,1000041,1000043,1000044,1000046,1000050,1000051,1000056]
    when 'production'
      (1000001..1000029).to_a + [1000035,1000036,1000039,1000040,1000041,1000043,1000044,1000046,1000050,1000051,1000056] + [1026617, 1026621, 1026623]
    end

    @majia_users = majia_ids.map {|id|
      User.find_by_id id
    }.compact
  end

  def zhimakaimen
#    @feeds = Feed.paginate(:conditions=>['event = ?','rolling'],:order=>'id desc',:per_page=>30,:page=>params[:page]||1)
    @feeds = Feed.normal.paginate(:per_page=>20,:page=>params[:page]||1)
  end

  def new_feed
    @feed = Feed.new
  end

  def create_feed
    @majia_user = @majia_users[rand(@majia_users.length)]

    feed = @majia_user.send_say_feed(params[:content],:detail=>params[:detail],:tags=>params[:tags],:event=>'rolling')
    if feed.id.blank?
      flash[:error]=get_flash_error(feed)
      return redirect_to '/zhi_ma_kai_men/feeds/new'
    end
    redirect_to '/zhi_ma_kai_men'
  end

  def edit_feed
    @feed = Feed.find(params[:id])
  end

  def update_feed
    @feed = Feed.find(params[:id])
    creator = @feed.creator

    @feed.update_all_attr(params[:content], params[:tags], params[:detail], creator)
    redirect_to "/zhi_ma_kai_men/show/#{@feed.id}"
  end

  def show_feed
    @feed = Feed.find(params[:id])
  end
  
  # ---------------------

  def new_vp
    @feed = Feed.find params[:feed_id]
  end
  
  def create_vp
    @feed = Feed.find params[:feed_id]
    
    # 排除已经参与过的人
    @target_users = @majia_users - [@feed.creator] - @feed.memoed_users

    if @target_users.blank?
      return render :text=>'啊，马甲用完了'
    end

    @majia_user = @target_users[rand(@target_users.length)]

    @viewpoint = @feed.create_or_update_viewpoint(@majia_user,params[:content])

    redirect_to "/zhi_ma_kai_men/show/#{@feed.id}"
  end
  
  def edit_vp
    @viewpoint = Viewpoint.find(params[:vp_id])
    @feed = @viewpoint.feed
  end
  
  def update_vp
    @viewpoint = Viewpoint.find(params[:vp_id])
    @feed = @viewpoint.feed
    user = @viewpoint.user
    
    @viewpoint = @feed.create_or_update_viewpoint(user,params[:content])

    redirect_to "/zhi_ma_kai_men/show/#{@feed.id}"
  end

  def up_user_img
    @user = User.find(params[:user_id])
  end

  def do_up_img
    @user = User.find(params[:user_id])
    @user.logo = params[:user][:logo]
    @user.save(:validate => false) # 某些马甲的邮箱 @mindpin.com 不符合规范，需要跳过校验
    redirect_to "/zhi_ma_kai_men/"
  end

  def xb
    
  end

end
