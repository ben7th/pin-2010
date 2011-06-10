module FavsEditFeedContentMethods
  def self.included(base)
    base.extend ClassMethods
    base.add_rules({
        :class => FeedRevision,
        :after_create => Proc.new{|feed_revision|
          feed = feed_revision.feed
          fvs = feed.feed_revisions
          fvs = fvs-[feed_revision]
          next if fvs.blank?
          
          UserTipProxy.create_favs_edit_feed_content_tip_on_queue(feed_revision)
        }
      })
  end

  module ClassMethods
    # 在 队列中 增加 收藏的话题被修改 提示
    def create_favs_edit_feed_content_tip_on_queue(feed_revision)
      UserTipResqueQueueWorker.async_user_tip(UserTipProxy::FAVS_EDIT_FEED_CONTENT,[feed_revision.id])
    end

    # 增加 收藏的话题被修改 提示
    def create_favs_edit_feed_content_tip(feed_revision)
      feed = feed_revision.feed
      operator = feed_revision.user
      self.create_favs_tip(UserTipProxy::FAVS_EDIT_FEED_CONTENT,feed,operator)
    end
  end
end
