module ViewpointSpamMarkEffectMethods
  def self.included(base)
    base.extend ClassMethods
    base.add_rules({
        :class => ViewpointSpamMark,
        :after_create => Proc.new{|vsm|
          viewpoint = vsm.viewpoint
          if viewpoint.spam_mark_effect?
            UserTipProxy.create_viewpoint_spam_mark_effect_tip_on_queue(viewpoint)
          end
        }
      })
  end

  def create_viewpoint_spam_mark_effect_tip(viewpoint)
    feed = viewpoint.feed
    tip_id = randstr

    tip_hash = {"feed_id"=>feed.id,"viewpoint_id"=>viewpoint.id,"kind"=>UserTipProxy::VIEWPOINT_SPAM_MARK_EFFECT,"time"=>Time.now.to_f.to_s}
    @rh.set(tip_id,tip_hash)
  end

  module ClassMethods
    # 在 队列中 增加 观点被确认 不值得讨论  提示
    def create_viewpoint_spam_mark_effect_tip_on_queue(viewpoint)
      UserTipResqueQueueWorker.async_user_tip(UserTipProxy::VIEWPOINT_SPAM_MARK_EFFECT,[viewpoint.id])
    end

    def create_viewpoint_spam_mark_effect_tip(viewpoint)
      UserTipProxy.new(viewpoint.user).create_viewpoint_spam_mark_effect_tip(viewpoint)
    end
  end
end
