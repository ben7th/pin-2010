class UserTipProxy < BaseTipProxy
  FAVS_EDIT_FEED_CONTENT = "favs_edit_feed_content"
  FAVS_ADD_VIEWPOINT = "favs_add_viewpoint"
  FAVS_EDIT_VIEWPOINT = "favs_edit_viewpoint"
  FEED_INVITE = "feed_invite"
  VIEWPOINT_VOTE_UP = "viewpoint_vote_up"
  VIEWPOINT_SPAM_MARK_EFFECT = "viewpoint_spam_mark_effect"

  FEED_SPAM_MARK_EFFECT = "feed_spam_mark_effect"
  VIEWPOINT_COMMENT = "viewpoint_comment"


  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_tip"
    @rh = RedisHash.new(@key)
  end

  def tips_count
    @rh.all.keys.count
  end

  # 这里只组织数据，不删除任何失效条目。
  # 否则会出现 tips_count 和 tips 数量上不一致的情况。
  # 显示在前端的效果就是 看见有通知数量提示，但却没有显示。体验不好。
  # 而且会导致这些本身有问题的key，永远不能被用户操作或者系统自动清除，白白占据内存
  # 这类异常，留给后续的层，比如helper去处理。
  def tips
    tips = []
    @rh.all.each do |tip_id,tip_hash|
      case tip_hash["kind"]
      when FAVS_EDIT_FEED_CONTENT
        tip = build_favs_tip(tip_id,tip_hash)
        tips.push(tip)
      when FAVS_ADD_VIEWPOINT
        tip = build_favs_tip(tip_id,tip_hash)
        tips.push(tip)
      when FAVS_EDIT_VIEWPOINT
        tip = build_favs_tip(tip_id,tip_hash)
        tips.push(tip)
      when FEED_INVITE
        feed = Feed.find_by_id(tip_hash["feed_id"])
        creator = User.find_by_id(tip_hash["creator_id"])
        kind = tip_hash["kind"]
        time = Time.at(tip_hash["time"].to_f)
        tip = Struct.new(:id,:feed,:creator,:kind,:time).new(tip_id,feed,creator,kind,time)
        tips.push(tip)
      when VIEWPOINT_VOTE_UP
        viewpoint = TodoUser.find_by_id(tip_hash["viewpoint_id"])
        voters_ids = tip_hash["voter_id"].to_s.split(",").uniq
        voters = voters_ids.map{|id|User.find_by_id(id)}.compact
        kind = tip_hash["kind"]
        time = Time.at(tip_hash["time"].to_f)
        tip = Struct.new(:id,:viewpoint,:voters,:kind,:time).new(tip_id,viewpoint,voters,kind,time)
        tips.push(tip)
      when VIEWPOINT_SPAM_MARK_EFFECT
        viewpoint = TodoUser.find_by_id(tip_hash["viewpoint_id"])
        feed = Feed.find_by_id(tip_hash["feed_id"])
        kind = tip_hash["kind"]
        time = Time.at(tip_hash["time"].to_f)
        tip = Struct.new(:id,:viewpoint,:feed,:kind,:time).new(tip_id,viewpoint,feed,kind,time)
        tips.push(tip)
      when FEED_SPAM_MARK_EFFECT
        feed = Feed.find_by_id(tip_hash["feed_id"])
        kind = tip_hash["kind"]
        time = Time.at(tip_hash["time"].to_f)
        tip = Struct.new(:id,:feed,:kind,:time).new(tip_id,feed,kind,time)
        tips.push(tip)
      when VIEWPOINT_COMMENT
        feed = Feed.find_by_id(tip_hash["feed_id"])
        viewpoint = TodoUser.find_by_id(tip_hash["viewpoint_id"])
        viewpoint_comment = TodoMemoComment.find_by_id(tip_hash["viewpoint_comment_id"])
        user = User.find_by_id(tip_hash["user_id"])
        kind = tip_hash["kind"]
        time = Time.at(tip_hash["time"].to_f)
        tip = Struct.new(:id,:feed,:viewpoint,:viewpoint_comment,:user,:kind,:time).new(tip_id,feed,viewpoint,viewpoint_comment,user,kind,time)
        tips.push(tip)
      end
    end
    tips.sort{|a,b|b.time<=>a.time}
  end

  def build_favs_tip(tip_id,tip_hash)
    feed = Feed.find_by_id(tip_hash["feed_id"])
    user = User.find_by_id(tip_hash["user_id"])
    kind = tip_hash["kind"]
    time = Time.at(tip_hash["time"].to_f)
    return if feed.blank? || user.blank?
    Struct.new(:id,:feed,:user,:kind,:time).new(tip_id,feed,user,kind,time)
  end

  def find_tip_id_by_hash(hash)
    @rh.all.each do |tip_id,tip_hash|
      return tip_id if tip_hash.merge(hash) == tip_hash
    end
    return
  end

  def self.rules
    @@rules||[]
  end

  extend QueueMethods
  include FavsMethods
  
  include FavsEditFeedContentMethods
  include FavsAddViewpointMethods
  include FavsEditViewpointMethods
  include FeedInviteMethods
  include ViewpointVoteUpMethods
  include ViewpointSpamMarkEffectMethods
  include FeedSpamMarkEffectMethods
  include ViewpointCommentMethods
end
