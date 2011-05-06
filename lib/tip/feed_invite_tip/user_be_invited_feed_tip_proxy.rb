=begin
      key user_xx_be_invited_feed_tip
      value {
              "#{randstr}"=>{"creator_id"=>"","feed_id"=>"","time"=>""},
              "#{randstr}"=>{"creator_id"=>"","feed_id"=>"","time"=>""}
            }
=end
class UserBeInvitedFeedTipProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_be_invited_feed_tip"
    @rh = RedisHash.new(@key)
  end

  def tips
    tips = []
    @rh.all.each do |tip_id,tip_hash|
      feed = Feed.find_by_id(tip_hash["feed_id"])
      creator = User.find_by_id(tip_hash["creator_id"])
      time = Time.at(tip_hash["time"].to_f)
      next if feed.blank? || creator.blank?
      tips.push(UserBeInvitedFeedTip.new(tip_id,feed,creator,time))
    end
    tips
  end

  def add_tip(feed_invite)
    feed = feed_invite.feed
    creator = feed_invite.creator
    tip_id = randstr
    tip_hash = {"feed_id"=>feed.id,"creator_id"=>creator.id,"time"=>Time.now.to_f.to_s}
    @rh.set(tip_id,tip_hash)
  end

  def remove_tip(feed_invite)
    feed = feed_invite.feed
    creator = feed_invite.creator
    @rh.all.each do |tip_id,tip_hash|
      if tip_hash["feed_id"].to_s == feed.id.to_s && tip_hash["creator_id"].to_s == creator.id.to_s
        return remove_tip_by_tip_id(tip_id)
      end
    end
  end

  def remove_all_tips
    @rh.del
  end

  def remove_tip_by_tip_id(tip_id)
    @rh.remove(tip_id)
  end

  class << self
    def add_tip(feed_invite)
      user = feed_invite.user
      self.new(user).add_tip(feed_invite)
    end

    def remove_tip(feed_invite)
      user = feed_invite.user
      self.new(user).remove_tip(feed_invite)
    end
  end

  module FeedInviteMethods
    def self.included(base)
      base.after_create :add_feed_invite_tip
      base.after_destroy :remove_feed_invite_tip
    end

    def add_feed_invite_tip
      UserBeInvitedFeedTipProxy.add_tip(self)
      return true
    end

    def remove_feed_invite_tip
      UserBeInvitedFeedTipProxy.remove_tip(self)
      return true
    end
  end

  class UserBeInvitedFeedTip
    attr_reader :id,:feed,:creator,:time
    def initialize(id,feed,creator,time)
      @id,@feed,@creator,@time = id,feed,creator,time
    end
  end
end
