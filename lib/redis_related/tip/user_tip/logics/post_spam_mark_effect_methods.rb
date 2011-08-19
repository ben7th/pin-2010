module PostSpamMarkEffectMethods
  def self.included(base)
    base.extend ClassMethods
    base.add_rules({
        :class => PostSpamMark,
        :after_create => Proc.new{|vsm|
          post = vsm.post
          if post.spam_mark_effect?
            UserTipProxy.create_post_spam_mark_effect_tip_on_queue(post)
          end
        }
      })
  end

  def create_post_spam_mark_effect_tip(post)
    feed = post.feed
    tip_id = randstr

    tip_hash = {"feed_id"=>feed.id,"post_id"=>post.id,"kind"=>UserTipProxy::POST_SPAM_MARK_EFFECT,"time"=>Time.now.to_f.to_s}
    @rh.set(tip_id,tip_hash)
  end

  module ClassMethods
    # 在 队列中 增加 观点被确认 不值得讨论  提示
    def create_post_spam_mark_effect_tip_on_queue(post)
      UserTipResqueQueueWorker.async_user_tip(UserTipProxy::POST_SPAM_MARK_EFFECT,[post.id])
    end

    def create_post_spam_mark_effect_tip(post)
      UserTipProxy.new(post.user).create_post_spam_mark_effect_tip(post)
    end
  end
end
