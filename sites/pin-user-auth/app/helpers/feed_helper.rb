module FeedHelper
  def activity_to_html(activity)
    begin
      operator = EmailActor.get_user_by_email(activity.operator)
      render :partial=>"activities/#{activity.event}",:locals=>{:activity=>activity,:operator=>operator}
    end
  rescue Exception => ex
    ex
  end

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

  def support_str(viewpoint)
    viewpoint.viewpoint_up_votes.map{|vote|
      link_to(vote.user.name,vote.user,:class=>'quiet')
    }*',' + ' 表示赞成'
  end

  def unsupport_str(viewpoint)
    "#{viewpoint.viewpoint_down_votes.length}人表示反对"
  end

  def str62keys
    [
      "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
      "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
      "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
    ]
  end

  def int10to62(num10)
    s62 = ''
    r = 0

    num = num10
    while num != 0 do
      r = num % 62
      s62 = str62keys[r] + s62
      num = (num / 62).floor
    end
    
    return s62
  end

  def int62to10(num62)
    i10 = 0
    
    arr = num62.split('')
    0.upto arr.length-1 do |i|
      n = arr.length - i - 1
      s = arr[i]
      i10 += str62keys.index(s) * 62**n
    end
    
    return i10
  end

  # mid转换为URL字符
  # mid 微博mid，如 "201110410216293360"
  # 微博URL字符，如 "wr4mOFqpbO"
  def mid2url(mid_input)
    url = ''
    
    mid = mid_input.to_s

    (mid.length - 7).step(-7,-7) do |i| #从最后往前以7字节为一组读取mid
      offset1 = i < 0 ? 0 : i;
      offset2 = i + 7;
      int10 = mid[offset1...offset2].to_i
      str = int10to62(int10)
      url = str + url;
    end

    url
  end

end
