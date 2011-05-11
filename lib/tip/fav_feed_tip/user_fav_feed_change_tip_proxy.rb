=begin
    key user_#{@user.id}_fav_feed_change_tip
    value {
            randstr=>{user_id=>xx,feed_id=>xx,kind=>xx}
          }
    kind 有三种 edit_feed_content|add_viewpoint|edit_viewpoint
=end
class UserFavFeedChangeTipProxy < BaseTipProxy
  definition_tip_attrs :id,:feed,:user,:kind,:time
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
      attrs = tip_hash_to_attrs(tip_id,tip_hash)
      next if attrs.blank?
      tips.push(UserFavFeedChangeTipProxy::Tip.new(*attrs))
    end
    tips
  end

  def tip_hash_to_attrs(tip_id,tip_hash)
    feed = Feed.find_by_id(tip_hash["feed_id"])
    user = User.find_by_id(tip_hash["user_id"])
    kind = tip_hash["kind"]
    time = Time.at(tip_hash["time"].to_f)
    return if feed.blank? || user.blank?
    [tip_id,feed,user,kind,time]
  end

  def add_tip(feed,operater,kind)
    tip_id =randstr
    tip_hash = {"feed_id"=>feed.id,"user_id"=>operater.id,:kind=>kind,"time"=>Time.now.to_f.to_s}
    @rh.set(tip_id,tip_hash)
  end
  
  class << self
    def add_tip(feed,operater,kind)
      users = feed.fav_users
      (users-[operater]).each do |user|
        UserFavFeedChangeTipProxy.new(user).add_tip(feed,operater,kind)
      end
    end

    def rules
      [
        {
          :class => FeedChange,
          :after_create => Proc.new{|feed_change|
            UserFavFeedChangeTipResqueQueueWorker.async_user_fav_feed_change_tip(
              feed_change.feed.id,feed_change.user.id,UserFavFeedChangeTipProxy::EDIT_FEED_CONTENT)
          }
        },
        {
          :class => TodoUser,
          :after_create => Proc.new{|todo_user|
            feed = todo_user.todo.feed
            UserFavFeedChangeTipResqueQueueWorker.async_user_fav_feed_change_tip(
              feed.id,todo_user.user.id,UserFavFeedChangeTipProxy::ADD_VIEWPOINT)
          },
          :after_update => Proc.new{|todo_user|
            next if todo_user.changes["memo"].blank?
            feed = todo_user.todo.feed
            UserFavFeedChangeTipResqueQueueWorker.async_user_fav_feed_change_tip(
              feed.id,todo_user.user.id,UserFavFeedChangeTipProxy::EDIT_VIEWPOINT)
          }
        }
      ]
    end
  end

end
