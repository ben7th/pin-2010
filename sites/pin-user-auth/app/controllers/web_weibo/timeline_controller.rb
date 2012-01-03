class WebWeibo::TimelineController < ApplicationController
  before_filter :login_required
  layout 'fullscreen'

  before_filter :deal_timeline_params, :only=>['home_timeline', 'user_timeline']
  def deal_timeline_params
    @weibo_params = {
      :since_id => params[:since_id],
      :max_id   => params[:max_id],
      :count    => params[:count],
      :page     => params[:page],
      :feature  => params[:feature]
    }
  end

  before_filter :deal_params, :only=>['atmes','comments_by_me','comments_by_me']
  def deal_params
    @weibo_params = {
      :since_id => params[:since_id],
      :max_id   => params[:max_id],
      :count    => params[:count],
      :page     => params[:page]
    }
  end

  def home_timeline
    @statuses = current_user.tsina_weibo.home_timeline(@weibo_params)
    if request.xhr?
      return render :partial=>'web_weibo/timeline/part/statuses', :locals=>{:statuses=>@statuses}
    end
  end

  def user_timeline
    @weibo_user_id = params[:uid]
    @statuses = current_user.tsina_weibo.user_timeline(@weibo_params.merge({:id=>@weibo_user_id}))
    if request.xhr?
      return render :partial=>'web_weibo/timeline/part/statuses', :locals=>{:statuses=>@statuses}
    end
  end

  # 某话题的微博，通过合并算法整理
  def trend_statuses
    
    @trend_name = params[:trend_name]

    if request.xhr?
      statuses = current_user.tsina_weibo.trends_statuses(@trend_name, :page=>params[:page], :count=>params[:count])
      return render :partial=>'web_weibo/timeline/part/statuses', :locals=>{:statuses=>statuses}
    else
      statuses = current_user.tsina_weibo.trends_statuses(@trend_name, :count=>50) # 最大就是50
      @bundles = WeiboStatus::Bundle.bundle_statuses(statuses)
    end
  end

  # @我的
  def atmes
    @weibo_user_id = current_user.tsina_connect_user.connect_id
    @statuses = current_user.tsina_weibo.mentions(@weibo_params)
    if request.xhr?
      return render :partial=>'web_weibo/timeline/part/statuses', :locals=>{:statuses=>@statuses}
    end
  end

  # 我发出的评论
  def comments_by_me
    @comments = current_user.tsina_weibo.comments_by_me(@weibo_params)
  end

  #   我收到的评论
  def comments_to_me
    @comments = current_user.tsina_weibo.comments_to_me(@weibo_params)
  end
end
