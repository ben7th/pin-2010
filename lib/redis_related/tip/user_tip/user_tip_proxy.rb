class UserTipProxy
  FAVS_EDIT_FEED_CONTENT    = "favs_edit_feed_content"
  FAVS_ADD_POST             = "favs_add_post"
  FAVS_EDIT_POST            = "favs_edit_post"
  FEED_INVITE               = "feed_invite"
  POST_VOTE_UP              = "post_vote_up"
  POST_SPAM_MARK_EFFECT     = "post_spam_mark_effect"

  FEED_SPAM_MARK_EFFECT     = "feed_spam_mark_effect"
  POST_COMMENT              = "post_comment"
  ATME                      = "atme"
  BE_FOLLOWED               = "be_followed"


  # 通知代理类是对一个用户的所有通知的包装
  # 查询，删除，等操作的范围都是针对这个用户的所有通知
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_tip"
    @rh = RedisTipHash.new(@key)
  end

  def rh
    @rh
  end

  #--------------组织数据相关方法
  #----------

  # 获得通知总数
  def tips_count
    clear_disabled_kind_tips
    @rh.all.keys.count
  end

  # 这里只组织数据，不删除任何失效条目。
  # 否则会出现 tips_count 和 tips 数量上不一致的情况。
  # 显示在前端的效果就是 看见有通知数量提示，但却没有显示。体验不好。
  # 而且会导致这些本身有问题的key，永远不能被用户操作或者系统自动清除，白白占据内存
  # 这类异常，留给后续的层，比如helper去处理。
  #
  # 获得所有通知的UserTip对象数组，按时间顺序倒序排序
  def tips
    clear_disabled_kind_tips
    tips = @rh.all.map do |tip_id,tip_hash|
      UserTip.build_by_tip_id_and_tip_hash(@user,tip_id,tip_hash)
    end
    tips.compact.sort{|a,b|b.time<=>a.time}
  end

  # 获得人际关系相关的tips数组
  def contacts_tips
    tips = tips
    kinds = [BE_FOLLOWED]
    tips.select{|tip|kinds.include?(tip.kind)}
  end


  #--------------------------------
  #-------获取UserTip对象的相关方法-----------------

  def get_tip_by_id(input_tip_id)
    tip_hash = @rh.get input_tip_id
    return nil if tip_hash.blank?
    UserTip.build_by_tip_id_and_tip_hash(@user,input_tip_id,tip_hash)
  end

  def get_tip_by_hash(input_tip_hash)
    @rh.all.each do |tip_id,tip_hash|
      if tip_hash.merge(input_tip_hash) == tip_hash
        return UserTip.build_by_tip_id_and_tip_hash(@user,tip_id,tip_hash)
      end
    end
    return nil
  end

  #---------------------------
  #----通知类型相关方法

  # 清理已经关闭的类型的通知
  def clear_disabled_kind_tips
    will_be_removed_ids = []
    enabled_kinds = UserTipProxy.enabled_kinds
    @rh.all.each do |tip_id,tip_hash|
      unless enabled_kinds.include?(tip_hash["kind"])
        will_be_removed_ids.push(tip_id)
      end
    end
    will_be_removed_ids.each{|id|@rh.remove(id)}
  end

  # 目前生效的通知类型
  def self.enabled_kinds
    @@enabled_kinds||=[]
  end

  # 增加通知类型
  def self.add_enabled_kinds(kind)
    self.enabled_kinds.push(kind)
    self.enabled_kinds.uniq!
  end

  # 清除所有通知
  def remove_all_tips
    @rh.del
  end

  #-----------------------
  #---规则定义相关方法

  # 取得所有规则
  def self.rules
    @@rules||=[]
  end

  # 增加规则
  def self.add_rules(rules)
    @@rules||=[]
    [rules].flatten.each do |rule|
      @@rules << rule
    end
  end


  # 给User类添加的实例方法
  def self.funcs
    {
      :class=> User,
      :tip_proxy=>Proc.new{|user|
        UserTipProxy.new(user)
      },
      :tips=>Proc.new{|user|
        tip_proxy.tips
      },
      :contacts_tips=>Proc.new{|user|
        tip_proxy.contacts_tips
      },
      :tips_count=>Proc.new{|user|
        tip_proxy.tips_count
      },
      :get_tip_by_id=>Proc.new{|user,tip_id|
        tip_proxy.get_tip_by_id(tip_id)
      }
    }
  end

  
  extend QueueMethods
  include FavsMethods

  include BeFollowedMethods
  #include FavsEditFeedContentMethods
  #include FavsAddPostMethods
  #include FavsEditPostMethods
#  include FeedInviteMethods 2011.5.31 由于邀请已在导航中单独显示，不再激活此通知
  #include PostVoteUpMethods
  #include PostSpamMarkEffectMethods
  #include FeedSpamMarkEffectMethods
  #include PostCommentMethods
end
