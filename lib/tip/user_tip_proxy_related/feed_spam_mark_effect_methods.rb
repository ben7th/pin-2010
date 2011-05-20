module FeedSpamMarkEffectMethods
  def self.included(base)
    base.extend ClassMethods
    base.add_rules({
        :class => SpamMark,
        :after_create => Proc.new{|sm|
          feed = sm.feed
          if feed.spam_mark_effect?
            UserTipProxy.create_feed_spam_mark_effect_tip_on_queue(feed)
          end
        }
      })
  end

  def create_feed_spam_mark_effect_tip(feed)
    tip_id = randstr

    tip_hash = {"feed_id"=>feed.id,"kind"=>UserTipProxy::FEED_SPAM_MARK_EFFECT,"time"=>Time.now.to_f.to_s}
    @rh.set(tip_id,tip_hash)
  end

  module ClassMethods
    # 在 队列中 增加 话题被确认 不值得讨论 提示
    def create_feed_spam_mark_effect_tip_on_queue(feed)
      UserTipResqueQueueWorker.async_user_tip(UserTipProxy::FEED_SPAM_MARK_EFFECT,[feed.id])
    end

    def create_feed_spam_mark_effect_tip(feed)
      UserTipProxy.new(feed.creator).create_feed_spam_mark_effect_tip(feed)
    end
  end
end
