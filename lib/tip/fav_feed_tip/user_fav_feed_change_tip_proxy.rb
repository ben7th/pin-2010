=begin
    key user_#{@user.id}_fav_feed_change_tip
    value {
            randstr=>{user_id=>xx,feed_id=>xx,kind=>xx}
          }
    kind 有三种 edit_feed_content|add_viewpoint|edit_viewpoint
=end
class UserFavFeedChangeTipProxy
  EDIT_FEED_CONTENT = "edit_feed_content"
  ADD_VIEWPOINT = "add_viewpoint"
  EDIT_VIEWPOINT = "edit_viewpoint"

  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_fav_feed_change_tip"
    @rh = RedisHash.new(@key)
  end

  def tips
    tips = []
    @rh.all.each do |tip_id,tip_hash|
      feed = Feed.find_by_id(tip_hash["feed_id"])
      user = User.find_by_id(tip_hash["user_id"])
      kind = tip_hash["kind"]
      time = Time.at(tip_hash["time"].to_f)
      next if feed.blank? || user.blank?
      tips.push(UserFavFeedChangeTip.new(tip_id,feed,user,kind,time))
    end
    tips
  end

  def add_tip(feed,operater,kind)
    tip_id =randstr
    tip_hash = {"feed_id"=>feed.id,"user_id"=>operater.id,:kind=>kind,"time"=>Time.now.to_f.to_s}
    @rh.set(tip_id,tip_hash)
  end
  
  def remove_all_tips
    @rh.del
  end
  
  def remove_tip_by_tip_id(tip_id)
    @rh.remove(tip_id)
  end

  class << self
    def add_tip(feed,operater,kind)
      users = feed.fav_users
      (users-[operater]).each do |user|
        UserFavFeedChangeTipProxy.new(user).add_tip(feed,operater,kind)
      end
    end
  end

  class UserFavFeedChangeTip
    attr_reader :tip_id,:feed,:user,:kind,:time
    def initialize(tip_id,feed,user,kind,time)
      @tip_id,@feed,@user,@kind,@time = tip_id,feed,user,kind,time
    end
  end

  module FeedChangeMethods
    def self.included(base)
      base.after_create :add_user_fav_feed_change_tip
    end

    def add_user_fav_feed_change_tip
      UserFavFeedChangeTipResqueQueueWorker.async_user_fav_feed_change_tip(
        self.feed.id,self.user.id,UserFavFeedChangeTipProxy::EDIT_FEED_CONTENT)
      return true
    end
  end

  module TodoUserMethods
    def self.included(base)
      base.after_create :add_user_fav_feed_change_tip_on_create
      base.after_update :add_user_fav_feed_change_tip_on_update
    end

    def add_user_fav_feed_change_tip_on_create
      feed = self.todo.feed
      UserFavFeedChangeTipResqueQueueWorker.async_user_fav_feed_change_tip(
        feed.id,self.user.id,UserFavFeedChangeTipProxy::ADD_VIEWPOINT)
      return true
    end

    def add_user_fav_feed_change_tip_on_update
      return true if self.changes["memo"].blank?
      feed = self.todo.feed
      UserFavFeedChangeTipResqueQueueWorker.async_user_fav_feed_change_tip(
        feed.id,self.user.id,UserFavFeedChangeTipProxy::EDIT_VIEWPOINT)
      return true
    end
  end
end
