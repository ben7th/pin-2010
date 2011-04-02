class NewsFeedProxy
  # 该类中的“缓存”均指代 REDIS

  # 构造喊出，目前接受user作为参数
  def initialize(user)
    @user = user
    @outbox_cache_key = "feed_vector_outbox_#{@user.id}"
    @inbox_cache_key  = "feed_vector_inbox_#{@user.id}"
    @refresh_newest_feed_id_cache_key = "refresh_newest_feed_id_#{@user.id}"
    @redis = RedisCache.instance
  end

  # feed是数据库持久化对象
  # 每当向数据库增加一条新 feed，其主体应该调用该方法以更新 REDIS 缓存
  def update_feed(feed)
    add_to_outbox_vector_cache(feed.id)
    
    add_to_fans_inbox_caches(feed.id)

    add_to_channels_vector_cache(feed)

    add_to_user_being_quoted_feeds_vector_cache(feed)
  end

  def delete_inbox_cache
    @redis.del(@inbox_cache_key)
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

  def remove_feed_id_from_outbox_vector_cache(feed_id)
    id_list = outbox_vector_cache
    if !id_list.blank?
      id_list.delete(feed_id)
      set_outbox_vector_cache(id_list)
    end
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

  def remove_feed_id_from_inbox_vector_cache(feed_id)
    id_list = inbox_vector_cache
    if !id_list.blank?
      id_list.delete(feed_id)
      set_inbox_vector_cache(id_list)
    end
  end

  def add_to_channels_vector_cache(feed)
    #用户的所有 fans
    #用户属于的所有频道的所有者
    channels = feed.channels_db
    if channels.blank?
      users = @user.hotfans + [@user]
      users.each do |user|
        NoChannelNewsFeedProxy.new(user).update_feed(feed)
      end
    else
      channels.each do |channel|
        ChannelNewsFeedProxy.new(channel).update_feed(feed)
      end
    end
  end

  def add_to_user_being_quoted_feeds_vector_cache(feed)
    if feed.quote_of
      qf = Feed.find_by_id(feed.quote_of)
      if qf
        UserBeingQuotedFeedsProxy.new(qf.creator).add_to_cache(feed.id)
      end
    end
  end

  # 关于feed读取的一组方法
  include FeedProxyReadMethods
  # 当好友关系发生改变时，同步 feed 的改变
  include FeedProxyModifyMethods

  module UserMethods
    def news_feeds
      Feed.news_feeds_of_user(self)
    end

    def news_feed_proxy
      NewsFeedProxy.new(self)
    end

    # 把当前用户作为联系人的在线用户
    # 暂时 忽略 在不在线
    def hotfans
      fans
    end

    def feeds_by_db(paginate_option={})
      _id_list = self.followings_and_self_by_db.map{|user|
        user.news_feeds.find(:all,:limit=>100,:order=>'id desc').map{|x| x.id}
      }.flatten
      # 排序，大的就是新的，排在前面
      _id_list = _id_list.compact.sort{|x,y| y<=>x}[0..99]

      if paginate_option.blank?
        first = 0
        count = _id_list.count
      else
        first = paginate_option[:per_page]*(paginate_option[:page]-1)
        count = paginate_option[:per_page]
      end
      _feeds = []
      _id_list[first..-1].each do |id|
        feed = Feed.find_by_id(id)
        if !feed.nil?
          _feeds.push(feed)
        end
        break if _feeds.count >= count
      end
      _feeds
    end
  end
end
