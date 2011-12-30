class WebWeibo::StatusesController < ApplicationController
  layout 'fullscreen'
  before_filter :login_required

  # 发一条微博
  def create
    feed = current_user.send_feed(
      :title          => params[:title],
      :detail         => params[:detail],
      :photo_ids      => params[:photo_ids],
      :collection_ids => params[:collection_ids],
      :from           => Feed::FROM_WEB,
      :send_tsina     => "true",
      :draft_token    => params[:draft_token],
      :location       => params[:location]
    )

    if feed.id.blank?
      flash[:error] = get_flash_error(feed)
      return render :text=>"创建失败 #{flash[:error]}"
    end
    render :text=>"创建成功"
  end

  # 单条微博显示
  def show
    @status = current_user.tsina_weibo.status(params[:mid])
    weibo_params = {
      :count    => params[:count],
      :page     => params[:page],
      :id=>params[:mid]
    }
    @comments = current_user.tsina_weibo.comments(weibo_params)
  end

  def add_comment
    # cid	要回复的评论ID。
    #without_mention 1: 回复中不自动加入“回复@用户名”，0：回复中自动加入“回复@用户名”.默认为0.
    #  comment_ori	false	int	当评论一条转发微博时，是否评论给原微博。0:不评论给原微博。1：评论给原微博。默认0.
    weibo_params = {
      :cid=>params[:cid],
      :without_mention=>params[:without_mention],
      :comment_ori=>params[:comment_ori]
    }
    current_user.tsina_weibo.comment(params[:mid],params[:comment],weibo_params)
  end

  # 获取当前的未读微博数
  def unread
    current_user.tsina_weibo.send(:perform_get,"/statuses/unread.json",:query=>{:with_new_status=>1,:since_id=>params[:since_id]})
  end
end
