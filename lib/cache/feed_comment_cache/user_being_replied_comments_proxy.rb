# 对 user 发送的 feeds 的 所有 feed_comments
class UserBeingRepliedCommentsProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{user.id}_being_replied_comments"
  end

  def xxxs_ids_db
    feeds = Feed.news_feeds_of_user(@user)
    ids = feeds.map{|feed|feed.feed_comments}.flatten.compact.map{|fc|fc.id}
    ids.sort{|x,y|y<=>x}
  end

  def self.rules
    {
      :class => FeedComment ,
      :after_create => Proc.new {|feed_comment|
        user = feed_comment.feed.creator
        UserBeingRepliedCommentsProxy.new(user).add_to_cache(feed_comment.id)
      },
      :after_destroy => Proc.new {|feed_comment|
        user = feed_comment.feed.creator
        UserBeingRepliedCommentsProxy.new(user).remove_from_cache(feed_comment.id)
      }
    }
  end
  
  def self.funcs
    {
      :class  => User ,
      :being_replied_comments => Proc.new {|user|
        UserBeingRepliedCommentsProxy.new(user).get_models(FeedComment)
      }
    }
  end
end
