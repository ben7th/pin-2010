module FeedHelper
  def user_last_feed(user)
    feed = user.out_newest_feed
    return if feed.nil?
    feed_title(feed)
  end

  def channel_last_feed(channel)
    feed = channel.newest_feed
    return if feed.nil?
    user = feed.creator
    "#{link_to user.name,user} #{feed_title(feed)}"
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

  def refresh_fans_tip
    MessageTip.new(current_user).refresh_fans_info if logged_in?
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

  def page_hot_users(limit = 32)
    # 查找活动数大于4的用户
    ActiveRecord::Base.connection.select_all(%~
      SELECT SUB.id,SUB.name,SUB.logo_file_name,COUNTU

      FROM (
        SELECT DISTINCT U.*,count(*) COUNTU
        FROM users U
        JOIN user_logs UL ON UL.user_id = U.id
        WHERE U.logo_file_name IS NOT NULL
        GROUP BY U.id
        ORDER BY COUNTU DESC
      ) SUB

      WHERE SUB.COUNTU >= 1
      LIMIT #{limit}
    ~).map{|item|User.find_by_id(item["id"])}.uniq.compact
  end

  def recent_feeds
    Feed.paginate(:per_page=>5,:page=>1,:order=>'id desc')
  end

  def mid2url(mid)
    WeiboStatus.mid2chars(mid)
  end
  
  def text_chs_length(str)
    l = 0
    
    str.unpack("U*").each do |asc|
      l += (asc<127 ? 0.5 : 1)
    end
    
    return l
  end

end
