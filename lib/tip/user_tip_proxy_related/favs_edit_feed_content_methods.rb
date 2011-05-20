module FavsEditFeedContentMethods
  def self.included(base)
    base.extend ClassMethods
    base.add_rules({
        :class => FeedChange,
        :after_create => Proc.new{|feed_change|
          UserTipProxy.create_favs_edit_feed_content_tip_on_queue(feed_change)
        }
      })
  end

  module ClassMethods
    # 在 队列中 增加 收藏的话题被修改 提示
    def create_favs_edit_feed_content_tip_on_queue(feed_change)
      UserTipResqueQueueWorker.async_user_tip(UserTipProxy::FAVS_EDIT_FEED_CONTENT,[feed_change.id])
    end

    # 增加 收藏的话题被修改 提示
    def create_favs_edit_feed_content_tip(feed_change)
      feed = feed_change.feed
      operator = feed_change.user
      self.create_favs_tip(UserTipProxy::FAVS_EDIT_FEED_CONTENT,feed,operator)
    end
  end
end
