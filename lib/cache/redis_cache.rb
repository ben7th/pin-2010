class RedisCache
  def self.instance
    @@instance ||= begin
      Redis.new(:thread_safe=>true)
    end
  end

  def self.load_proxy(klass)
    rules = klass.rules
    raise("#{klass} cache rules 未定义") if rules.nil?
    [rules].flatten.each do |r|
      @@rules << r
    end

    funcs = klass.funcs
    raise("#{klass} cache funcs 未定义") if funcs.nil?
    [funcs].flatten.each do |f|
      @@funcs << f
    end
  end

  def self.refresh_cache_by_rules(model,callback_type)
    @@rules.each do |r|
      if (r[:class] == model.class) && !r[callback_type].nil?
        r[callback_type].call(model)
      end
    end
  end

  def self.has_method?(model,method_id)
    !self.get_method(model,method_id).nil?
  end

  def self.get_method(model,method_id)
    @@funcs.each do |f|
      if (f[:class] == model.class) && !f[method_id].nil?
        return f
      end
    end
    return nil
  end

  def self.do_method(model,method_id,*args)
    func = self.get_method(model,method_id)
    func[method_id].call(model,*args)
  end

  @@rules = []
  @@funcs = []
  # 标注 feed 缓存
  RedisCache.load_proxy(UserFavFeedsProxy)
  RedisCache.load_proxy(FeedFavUsersProxy)

  # 联系人缓存
  RedisCache.load_proxy(FansProxy)
  RedisCache.load_proxy(FollowingsProxy)

  # 频道缓存
  RedisCache.load_proxy(UserChannelsCacheProxy)
  RedisCache.load_proxy(ChannelUsersCacheProxy)
  RedisCache.load_proxy(BlongsChannelsOfUserProxy)

  # 协同导图缓存
  RedisCache.load_proxy(UserCooperateMindmapsProxy)

  # feed mindmap 缓存
  RedisCache.load_proxy(FeedsOfMindmapProxy)
  RedisCache.load_proxy(MindmapsOfFeedProxy)

  # 标注导图缓存
  RedisCache.load_proxy(UserFavMindmapsProxy)
  RedisCache.load_proxy(MindmapFavUsersProxy)


  # feed_comment 缓存
  RedisCache.load_proxy(UserBeingRepliedCommentsProxy)

  # feed 缓存
  RedisCache.load_proxy(UserOutboxFeedProxy)
  RedisCache.load_proxy(UserInboxFeedProxy)
  RedisCache.load_proxy(UserNoChannelFeedProxy)
  RedisCache.load_proxy(ChannelFeedProxy)
  RedisCache.load_proxy(UserBeingQuotedFeedsProxy)
  RedisCache.load_proxy(UserMemoedFeedsProxy)
  RedisCache.load_proxy(UserBeInvitedFeedsProxy)

  # log 缓存
  RedisCache.load_proxy(UserOutboxLogProxy)
  RedisCache.load_proxy(UserInboxLogProxy)
  # ---------- 每增加一个子proxy就配置在这里
  # 用到闭包，method_missing等一些手段，来减少冗余代码
end