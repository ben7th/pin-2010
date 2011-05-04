module FeedHelper
  def activity_to_html(activity)
    begin
      operator = EmailActor.get_user_by_email(activity.operator)
      render :partial=>"activities/#{activity.event}",:locals=>{:activity=>activity,:operator=>operator}
    end
  rescue Exception => ex
    ex
  end

  def feed_content(feed)
    "#{auto_link(h(feed.content),:html=>{:target=>'_blank'})}"
  end

  def vp_memo(todo_user)
    "#{auto_link(ct(todo_user.memo),:html=>{:target=>'_blank'})}"
  end

  def vp_memo_short(todo_user)
    "#{auto_link(ct(truncate_u(todo_user.memo,128)),:html=>{:target=>'_blank'})}"
  end

  def j_vp_memo(todo_user)
    t1 = todo_user.memo
    t2 = truncate_u(todo_user.memo,128)
    if t1.length == t2.length
      vp_memo(todo_user)
    else
      %~
        <div class='short-content'>#{vp_memo_short(todo_user)} <a href='javascript:;' class='show-detail font12'>显示全部</a></div>
        <div class='detail-content' style='display:none;'>#{vp_memo(todo_user)}</div>
      ~
    end
  end

  def user_last_feed(user)
    feed = user.out_newest_feed
    return if feed.nil?
    feed_content(feed)
  end

  def channel_last_feed(channel)
    feed = channel.newest_feed
    return if feed.nil?
    user = feed.creator
    "#{link_to user.name,user} #{feed_content(feed)}"
  end

  def feed_preview(feed)
    ''
  end

  def misc_tip_info
    if logged_in?
      MessageTip.new(current_user).newest_info
    else
      Hash.new(0)
    end
  end

  def refresh_feed_tip
    MessageTip.new(current_user).refresh_feeds_info if logged_in?
  end

  def refresh_comment_tip
    MessageTip.new(current_user).refresh_comments_info if logged_in?
  end

  def refresh_quote_tip
    MessageTip.new(current_user).refresh_quotes_info if logged_in?
  end

  def refresh_todo_tip
    MessageTip.new(current_user).refresh_todos_info if logged_in?
  end

  def refresh_fans_tip
    MessageTip.new(current_user).refresh_fans_info if logged_in?
  end

  def usersign(user, sign = true)
    re = []
    if user.blank?
      re << '未知用户'
    else
      re << "#{link_to user.name,user,:class=>'bold'}"
      if !user.sign.blank? && sign
        re << "<span class='quiet'>，#{truncate_u user.sign,24}</span>"
      end
    end
    return re
  end

  def comment_link(model)
    re = []
    if model.blank?
      re << ''
    elsif model.comments.count > 0
      re << "#{model.comments.count}条评论"
    else
      re << '评论'
    end
    return re
  end

  def viewpoint_link(feed)
    re = []
    if feed.blank?
      re << ''
    elsif feed.viewpoints.blank?
      re << '没有观点'
    else
      re << "#{feed.viewpoints.count}个观点"
    end
    return re
  end

  def page_hot_users
    User.find(
      :all,
      :select=>'DISTINCT users.*',
      :joins=>'JOIN feeds ON feeds.creator_id = users.id',
      :conditions=>['logo_file_name IS NOT NULL'],
      :limit=>32,
      :order=>'feeds.id desc'
    )
  end

  def recent_feeds
    Feed.paginate(:per_page=>5,:page=>1,:order=>'id desc')
  end

  def hot_discuss_feeds
    Feed.find(
      :all,
      :select=>'DISTINCT feeds.*',
      :joins=>'JOIN todos on todos.feed_id = feeds.id',
      :limit=>10,
      :order=>'feeds.id desc'
    )
  end

  def support_str(todo_user)
    todo_user.viewpoint_up_votes.map{|vote|
      link_to(vote.user.name,vote.user,:class=>'quiet')
    }*',' + ' 表示赞成'
  end

  def unsupport_str(todo_user)
    "#{todo_user.viewpoint_down_votes.length}人表示反对"
  end

  def vote_up_tip_str(vote_tip)
    voters = vote_tip.voters
    feed = vote_tip.viewpoint.todo.feed

    re = []

    vre = []
    voters.each do |voter|
      vre << link_to(voter.name,voter)
    end

    re << vre*','
    re << '对于你在话题'
    re << link_to(truncate_u(feed.content,16),feed)
    re << '中的观点表示赞成'
    re << "<span class='quiet'>#{jtime vote_tip.time}</span>"
    return re*' '
  rescue Exception => ex
    return "提示信息解析错误#{ex}" if RAILS_ENV == 'development'
    return ''
  end
end
