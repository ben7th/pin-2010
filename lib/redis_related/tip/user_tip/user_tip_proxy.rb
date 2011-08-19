class UserTipProxy
  FAVS_EDIT_FEED_CONTENT = "favs_edit_feed_content"
  FAVS_ADD_POST = "favs_add_post"
  FAVS_EDIT_POST = "favs_edit_post"
  FEED_INVITE = "feed_invite"
  POST_VOTE_UP = "post_vote_up"
  POST_SPAM_MARK_EFFECT = "post_spam_mark_effect"

  FEED_SPAM_MARK_EFFECT = "feed_spam_mark_effect"
  POST_COMMENT = "post_comment"
  ATME = "atme"
  BE_FOLLOWED = "be_followed"


  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_tip"
    @rh = RedisTipHash.new(@key)
  end

  def rh
    @rh
  end

  def clear_disable_kind_tips
    clear_ids = []
    enable_kinds = UserTipProxy.enable_kinds
    @rh.all.each do |tip_id,tip_hash|
      unless enable_kinds.include?(tip_hash["kind"])
        clear_ids.push(tip_id)
      end
    end
    clear_ids.each{|id|@rh.remove(id)}
  end

  def tips_count
    clear_disable_kind_tips
    @rh.all.keys.count
  end

  # 这里只组织数据，不删除任何失效条目。
  # 否则会出现 tips_count 和 tips 数量上不一致的情况。
  # 显示在前端的效果就是 看见有通知数量提示，但却没有显示。体验不好。
  # 而且会导致这些本身有问题的key，永远不能被用户操作或者系统自动清除，白白占据内存
  # 这类异常，留给后续的层，比如helper去处理。
  def tips
    clear_disable_kind_tips
    tips = @rh.all.map do |tip_id,tip_hash|
      UserTip.build_by_tip_id_and_tip_hash(@user,tip_id,tip_hash)
    end
    tips.compact.sort{|a,b|b.time<=>a.time}
  end

  def contacts_tips
    tips = tips
    kinds = [BE_FOLLOWED]
    tips.select{|tip|kinds.include?(tip.kind)}
  end

  def find_tip_id_by_hash(hash)
    @rh.all.each do |tip_id,tip_hash|
      return tip_id if tip_hash.merge(hash) == tip_hash
    end
    return
  end

  def find_tip_hash_by_id(tip_id)
    @rh.all.each do |tip_id,tip_hash|
      return tip_hash if tip_id == tip_id
    end
    return
  end

  def self.enable_kinds
    @@enable_kinds||=[]
  end

  def self.add_enable_kinds(kind)
    enable_kinds = self.enable_kinds
    enable_kinds.push(kind).uniq!
  end

  def self.rules
    @@rules||=[]
  end

  def self.funcs
    {
      :class=> User,
      :tips=>Proc.new{|user|
        UserTipProxy.new(user).tips
      },
      :contacts_tips=>Proc.new{|user|
        UserTipProxy.new(user).contacts_tips
      },
      :tips_count=>Proc.new{|user|
        UserTipProxy.new(user).tips_count
      },
      :get_tip_by_id=>Proc.new{|user,tip_id|
        tip = UserTip.build_by_tip_id(user,tip_id)
        tip.remove()
      }
    }
  end

  def remove_all_tips
    @rh.del
  end

  def self.add_rules(rules)
    @@rules||=[]
    [rules].flatten.each do |rule|
      @@rules << rule
    end
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
