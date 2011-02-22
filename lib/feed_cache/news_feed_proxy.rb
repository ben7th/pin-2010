class NewsFeedProxy
  # 该类中的“缓存”均指代 REDIS

  # 构造喊出，目前接受user作为参数
  def initialize(user)
    @user = user
    @email = @user.email
    @outbox_cache_key = "feed_vector_outbox_#{@email}"
    @inbox_cache_key  = "feed_vector_inbox_#{@email}"
    @refresh_newest_feed_id_cache_key = "refresh_newest_feed_id_#{@email}"
    @redis = RedisCache.instance
  end

  # feed是数据库持久化对象
  # 每当向数据库增加一条新 feed，其主体应该调用该方法以更新 REDIS 缓存
  def update_feed(feed)
    add_to_outbox_vector_cache(feed.id)
    
    add_to_fans_inbox_caches(feed.id)
  end

  # 更新outbox向量缓存
  # 向量缓存指，只包含要缓存的对象ID的数组，twitter里面大量用了这类缓存设计
  # 把新的 feed_id 加到 list 的最前
  # list 最大长度 100 条，超过100条，则去掉末尾的
  def add_to_outbox_vector_cache(feed_id)
    _id_list_old = outbox_vector_cache
    if _id_list_old.nil?
      # 1月19日，为了应对清空缓存后恢复的问题，保持outbox的始终完整性
      # 如果缓存不存在，设置时先取数据库一次
      outbox_id_list_newer_than(nil) # 此方法会设置缓存，并且取出的值不超过100个
    else
      _id_list_old.unshift(feed_id)
      _id_list_old = _id_list_old[0..99] if _id_list_old.length > 100
      set_outbox_vector_cache(_id_list_old)
    end
  end

  # 尝试读取outbox向量缓存，
  # 返回 nil 表示缓存无效，
  # 返回 [] 表示无内容，请注意区分
  def outbox_vector_cache
    return nil if !@redis.exists(@outbox_cache_key)
    id_list_json = @redis.get(@outbox_cache_key)
    ActiveSupport::JSON.decode(id_list_json)
  end

  # 完全替换outbox向量缓存内容
  def set_outbox_vector_cache(id_list)
    @redis.set(@outbox_cache_key,id_list.to_json)
  end

  # user上需要实现hotfans方法，来获取活跃粉丝
  # 更新所有活跃粉丝的inbox
  def add_to_fans_inbox_caches(feed_id)
    hotfans = @user.hotfans
    hotfans.each do |fan|
      fan.news_feed_proxy.add_to_inbox_vector_cache(feed_id)
    end
  end

  # 更新inbox向量缓存
  # 把新的 feed_id 加到 list 的最前
  # list 最大长度 200 条，超过200条，则去掉末尾的
  # 每页20条的情况下，可以翻10页
  # 更新 inbox vector cache
  # 把新的 feed_id 加到 list 的最前
  def add_to_inbox_vector_cache(feed_id)
    _id_list_old = inbox_vector_cache
    if _id_list_old.nil?
      # 1月19日，为了应对清空缓存后恢复的问题，保持outbox的始终完整性
      # 如果缓存不存在，设置时先取数据库一次
      inbox_id_list # 此方法会设置缓存，并且取出的值不超过100个
    else
      _id_list_old.unshift(feed_id)
      _id_list_old = _id_list_old[0..199] if _id_list_old.length > 200
      set_inbox_vector_cache(_id_list_old)
    end
  end

  # 尝试读取inbox向量缓存，
  # 返回 nil 表示缓存无效，
  # 返回 [] 表示无内容，请注意区分
  def inbox_vector_cache
    return nil if !@redis.exists(@inbox_cache_key)
    id_list_json = @redis.get(@inbox_cache_key)
    ActiveSupport::JSON.decode(id_list_json)
  end

  # 完全替换inbox向量缓存内容
  def set_inbox_vector_cache(id_list)
    @redis.set(@inbox_cache_key,id_list.to_json)
  end

  # 关于feed读取的一组方法
  include FeedProxyReadMethods

end
