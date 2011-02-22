module FeedProxyReadMethods
  # 获取对象需要看到的feeds
  # 该读缓存读缓存，该读数据库读数据库哈
  def feeds
    _feeds = inbox_id_list.map {|id|
      Feed.find_by_id(id) # 这里已经被 cache-money 缓存了
    }.compact
    _feeds
  end

  # 获取对象发布的 feeds
  # 该读缓存读缓存，该读数据库读数据库哈
  def own_feeds
    _feeds = outbox_id_list.map {|id|
      Feed.find_by_id(id) # 这里已经被 cache-money 缓存了
    }.compact
    _feeds
  end

  # 最新的一条 feed
  def own_newest_feed
    feed_id = outbox_id_list.first
    Feed.find_by_id(feed_id) if !feed_id.nil?
  end

  def refresh_newest_feed_id
    @redis.set(@refresh_newest_feed_id_cache_key,feeds.first.id)
  rescue
    @redis.set(@refresh_newest_feed_id_cache_key,0)
  end

  def newest_feed_id
    if !@redis.exists(@refresh_newest_feed_id_cache_key)
      refresh_newest_feed_id
    end
    @redis.get(@refresh_newest_feed_id_cache_key).to_i
  end

  def newsfeed_ids(current_id = nil)
    current_id = newest_feed_id if current_id.nil?
    inbox_id_list.select{|id|id>(current_id.to_i)}
  end

  # 获取对象 发出 feeds的id数组
  # 该读缓存读缓存，该读数据库读数据库
  def outbox_id_list
    # 读取 @outbox_key 对应缓存
    _id_list = outbox_vector_cache
    if _id_list.nil?
      return outbox_id_list_newer_than(nil)
    end
    return _id_list
  end

  # 获取对象需要看到的feeds的id数组
  # 该读缓存读缓存，该读数据库读数据库
  def inbox_id_list
    # 先读 inbox 缓存，如果缓存读出nil，再读每个关注对象的 outbox，来聚合feed
    _id_list = inbox_vector_cache
    re = []
    if _id_list.nil?
      # nil 缓存无效
      re = _inbox_id_list_from_followings_newer_than(nil)
    elsif _id_list == []
      # 空数组
      re = _inbox_id_list_from_followings_newer_than(nil)
    else
      # 有值，则取比最新一个更新发布的
      newest_id = _id_list.first
      _id_list_new = _inbox_id_list_from_followings_newer_than(newest_id)
      _id_list = [] if _id_list.nil?
      re = _id_list_new + _id_list
    end
    re.sort!{|x,y| y<=>x}
    re = re[0..199]

    # 并且设置 inbox 缓存
    set_inbox_vector_cache(re)
    
    return re
  end

  # 读取所有当前用户的关注对象的 outbox_id_list 并聚合
  # 如果 newest_id 有效，则只返回比它更新的
  def _inbox_id_list_from_followings_newer_than(newest_id)
    # 写入inbox缓存
    _id_list = @user.following_users.map{|user|
      user.news_feed_proxy.outbox_id_list_newer_than(newest_id)
    }.flatten

    # 排序，大的就是新的，排在前面
    return _id_list.sort{|x,y| y<=>x}
  end

  # 获取对象的 outbox 的 id 数组
  # 如果 newest_id 有效，则只读取比它更新的
  # 该读缓存读缓存，该读数据库读数据库
  def outbox_id_list_newer_than(newest_id)
    # 读取 @outbox_key 对应缓存
    _id_list = outbox_vector_cache

    re = []
    if _id_list.nil?
      # TODO 读取数据库记录中的最后100条 # 整个过程只有此处读数据库
      _newest_ids = @user.news_feeds.find(:all,:limit=>100,:order=>'id desc').map{|x| x.id}
      set_outbox_vector_cache _newest_ids
      re = _newest_ids
    elsif _id_list == []
      re = []
    else
      re = _id_list
    end

    if !newest_id.nil?
      re = re.select{|x| x>newest_id}
    end

    re
  end
end
