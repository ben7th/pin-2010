class MindpinLogicManagement

  REDIS_LOGIC = :redis_logic
  REPUTATION_LOGIC = :reputation_logic
  TIP_LOGIC = :tip_logic

  def self.load_redis_proxy(klass)
    load_proxy(klass,REDIS_LOGIC)
  end
  
  def self.load_reputation_proxy(klass)
    load_proxy(klass,REPUTATION_LOGIC)
  end
  
  def self.load_tip_proxy(klass)
    load_proxy(klass,TIP_LOGIC)
  end

  def self.load_proxy(klass,logic_type)
    rules = klass.rules
    raise("#{klass} cache rules 未定义") if rules.nil?
    [rules].flatten.each do |r|
      @@rules[logic_type] << r
    end

    funcs = klass.funcs
    raise("#{klass} cache funcs 未定义") if funcs.nil?
    [funcs].flatten.each do |f|
      @@funcs << f
    end
  end
  
  def self.run_all_logic_by_rules(model, callback_type)
    self.run_logic_by_rules(model, REDIS_LOGIC, callback_type)
    self.run_logic_by_rules(model, REPUTATION_LOGIC, callback_type)
    self.run_logic_by_rules(model, TIP_LOGIC, callback_type)
  end

  def self.run_logic_by_rules(model, logic_type, callback_type)
    @@rules[logic_type].each do |r|
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
  
  @@rules = {
    REDIS_LOGIC=>[],
    REPUTATION_LOGIC=>[],
    TIP_LOGIC=>[]
    }

  @@funcs = []

  # redis
    # 标注 feed 缓存
    MindpinLogicManagement.load_redis_proxy UserFavFeedsProxy
    MindpinLogicManagement.load_redis_proxy FeedFavUsersProxy

    # 联系人缓存
    MindpinLogicManagement.load_redis_proxy FansProxy
    MindpinLogicManagement.load_redis_proxy FollowingsProxy

    # 频道缓存
    MindpinLogicManagement.load_redis_proxy UserChannelsCacheProxy
    MindpinLogicManagement.load_redis_proxy ChannelUsersCacheProxy
    MindpinLogicManagement.load_redis_proxy BlongsChannelsOfUserProxy

    # 协同导图缓存
    MindpinLogicManagement.load_redis_proxy UserCooperateMindmapsProxy


    # 标注导图缓存
    MindpinLogicManagement.load_redis_proxy UserFavMindmapsProxy
    MindpinLogicManagement.load_redis_proxy MindmapFavUsersProxy

    # feed_comment 缓存
    MindpinLogicManagement.load_redis_proxy UserBeingRepliedCommentsProxy

    # feed 缓存
    MindpinLogicManagement.load_redis_proxy(UserOutboxFeedProxy)
    MindpinLogicManagement.load_redis_proxy(UserInboxFeedProxy)
    MindpinLogicManagement.load_redis_proxy(UserChannelOutboxFeedProxy)
    
    MindpinLogicManagement.load_redis_proxy(UserBeingQuotedFeedsProxy)
    MindpinLogicManagement.load_redis_proxy(UserMemoedFeedsProxy)
    MindpinLogicManagement.load_redis_proxy(UserBeInvitedFeedsProxy)
    MindpinLogicManagement.load_redis_proxy(UserFavTagFeedsProxy)

    # log 缓存
    MindpinLogicManagement.load_redis_proxy(UserOutboxLogProxy)
    MindpinLogicManagement.load_redis_proxy(UserInboxLogProxy)

    # viewpoint 缓存
    MindpinLogicManagement.load_redis_proxy(UserHotViewpointsProxy)

    # tag 缓存
    MindpinLogicManagement.load_redis_proxy(UserFavTagsProxy)
    MindpinLogicManagement.load_redis_proxy(TagFavUsersProxy)

    # mindmap 缓存
    MindpinLogicManagement.load_redis_proxy(UserMindmapsMajorWordsProxy)
    MindpinLogicManagement.load_redis_proxy(UserOutboxMindmapProxy)
    MindpinLogicManagement.load_redis_proxy(UserInboxMindmapProxy)

  # tip
    MindpinLogicManagement.load_tip_proxy(UserTipProxy)
    MindpinLogicManagement.load_tip_proxy(UserJoinedFeedsChangeTipProxy)

  # reputation
    MindpinLogicManagement.load_reputation_proxy ViewpointVoteReputationProxy
    MindpinLogicManagement.load_reputation_proxy FeedVoteReputationProxy
end
