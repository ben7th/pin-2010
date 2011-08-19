class UserTip
  def initialize(user,attrs_hash)
    @user = user
    @attrs_hash = attrs_hash
  end

  def method_missing_with_find_attr(symbol, *args)
    attr = @attrs_hash[symbol]
    if attr.blank?
      method_missing_without_find_attr(symbol, *args)
    else
      attr
    end
  end
  alias_method_chain :method_missing, :find_attr

  def remove
    UserTipProxy.new(@user).rh.remove(id)
  end

  def self.build_by_tip_id(user,tip_id)
    tip_hash = UserTipProxy.new(user).find_tip_hash_by_id(tip_id)
    self.build_by_tip_id_and_tip_hash(tip_id,tip_hash)
  end

  def self.build_by_tip_id_and_tip_hash(user,tip_id,tip_hash)
    attrs_hash = case tip_hash["kind"]
    when UserTipProxy::BE_FOLLOWED
      self.build_be_followed_tip(tip_id,tip_hash)
    end
    return if attrs_hash.blank?
    self.new(user,attrs_hash)
  end
  
  def self.build_be_followed_tip(tip_id,tip_hash)
    channel_user = ChannelUser.find_by_id(tip_hash["channel_user_id"])
    return if channel_user.blank?
    channel = channel_user.channel
    return if channel.blank?
    user = channel.creator
    kind = tip_hash["kind"]
    time = Time.at(tip_hash["time"].to_f)
    {:id=>tip_id,:user=>user,:kind=>kind,:time=>time}
  end

  ##########################
  def xx
    tip_hash = case tip_hash["kind"]
    when FAVS_EDIT_FEED_CONTENT
      build_favs_tip(tip_id,tip_hash)
    when FAVS_ADD_POST
      build_favs_tip(tip_id,tip_hash)
    when FAVS_EDIT_POST
      build_favs_tip(tip_id,tip_hash)
    when FEED_INVITE
      feed = Feed.find_by_id(tip_hash["feed_id"])
      creator = User.find_by_id(tip_hash["creator_id"])
      kind = tip_hash["kind"]
      time = Time.at(tip_hash["time"].to_f)
      {:id=>tip_id,:feed=>feed,:creator=>creator,:kind=>kind,:time=>time}
    when POST_VOTE_UP
      post = post.find_by_id(tip_hash["post_id"])
      voters_ids = tip_hash["voter_id"].to_s.split(",").uniq
      voters = voters_ids.map{|id|User.find_by_id(id)}.compact
      kind = tip_hash["kind"]
      time = Time.at(tip_hash["time"].to_f)
      {:id=>tip_id,:post=>post,:voters=>voters,:kind=>kind,:time=>time}
    when POST_SPAM_MARK_EFFECT
      post = post.find_by_id(tip_hash["post_id"])
      feed = Feed.find_by_id(tip_hash["feed_id"])
      kind = tip_hash["kind"]
      time = Time.at(tip_hash["time"].to_f)
      {:id=>tip_id,:post=>post,:feed=>feed,:kind=>kind,:time=>time}
    when FEED_SPAM_MARK_EFFECT
      feed = Feed.find_by_id(tip_hash["feed_id"])
      kind = tip_hash["kind"]
      time = Time.at(tip_hash["time"].to_f)
      {:id=>tip_id,:feed=>feed,:kind=>kind,:time=>time}
    when POST_COMMENT
      feed = Feed.find_by_id(tip_hash["feed_id"])
      post = post.find_by_id(tip_hash["post_id"])
      post_comment = postComment.find_by_id(tip_hash["post_comment_id"])
      user = User.find_by_id(tip_hash["user_id"])
      kind = tip_hash["kind"]
      time = Time.at(tip_hash["time"].to_f)
      {:id=>tip_id,:feed=>feed,:post=>post,
        :post_comment=>post_comment,:user=>user,:kind=>kind,:time=>time}
    when ATME
      atme = Atme.find_by_id(tip_hash["atme_id"])
      next if atme.blank?
      atable = atme.atable
      next if atable.blank?

      kind = tip_hash["kind"]
      time = Time.at(tip_hash["time"].to_f)
      tip = Struct.new(:id,:atable,:kind,:time).new(tip_id,atable,kind,time)
      tips.push(tip)
    when BE_FOLLOWED
      channel_user = ChannelUser.find_by_id(tip_hash["channel_user_id"])
      next if channel_user.blank?
      channel = channel_user.channel
      next if channel.blank?
      user = channel.creator
      kind = tip_hash["kind"]
      time = Time.at(tip_hash["time"].to_f)
      tip = Struct.new(:id,:user,:kind,:time).new(tip_id,user,kind,time)
    end
  end

  def self.build_favs_tip(tip_id,tip_hash)
    feed = Feed.find_by_id(tip_hash["feed_id"])
    user = User.find_by_id(tip_hash["user_id"])
    kind = tip_hash["kind"]
    time = Time.at(tip_hash["time"].to_f)
    return if feed.blank? || user.blank?
    {:id=>tip_id,:feed=>feed,:user=>user,:kind=>kind,:time=>time}
  end
  
end
