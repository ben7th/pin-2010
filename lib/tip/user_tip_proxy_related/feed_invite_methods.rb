module FeedInviteMethods
  def self.included(base)
    base.extend ClassMethods
    base.add_rules({
        :class => FeedInvite,
        :after_create => Proc.new{|feed_invite|
          UserTipProxy.create_feed_invite_tip_on_queue(feed_invite)
        },
        :after_destroy => Proc.new{|feed_invite|
          UserTipProxy.destroy_feed_invite_tip(feed_invite)
        }
      })
  end

  def create_feed_invite_tip(feed,creator)
    tip_id = find_tip_id_by_hash({"feed_id"=>feed.id,"creator_id"=>creator.id,"kind"=>UserTipProxy::FEED_INVITE})
    if tip_id.blank?
      tip_id = randstr
      tip_hash = {"feed_id"=>feed.id,"creator_id"=>creator.id,"kind"=>UserTipProxy::FEED_INVITE,"time"=>Time.now.to_f.to_s}
    else
      tip_hash = @rh.get(tip_id)
      tip_hash["time"] = Time.now.to_f.to_s
    end
    @rh.set(tip_id,tip_hash)
  end

  def destroy_feed_invite_tip(feed,creator)
    @rh.all.each do |tip_id,tip_hash|
      if tip_hash["kind"] == UserTipProxy::FEED_INVITE && tip_hash["feed_id"].to_s == feed.id.to_s && tip_hash["creator_id"].to_s == creator.id.to_s
        return remove_tip_by_tip_id(tip_id)
      end
    end
  end

  module ClassMethods
    # 在 队列中 增加 被邀请参加话题 提示
    def create_feed_invite_tip_on_queue(feed_invite)
      UserTipResqueQueueWorker.async_user_tip(UserTipProxy::FEED_INVITE,[feed_invite.id])
    end

    # 被邀请参加话题
    def create_feed_invite_tip(feed_invite)
      feed = feed_invite.feed
      creator = feed_invite.creator
      user = feed_invite.user

      UserTipProxy.new(user).create_feed_invite_tip(feed,creator)
    end

    def destroy_feed_invite_tip(feed_invite)
      feed = feed_invite.feed
      creator = feed_invite.creator

      UserTipProxy.new(feed_invite.user).destroy_feed_invite_tip(feed,creator)
    end
  end
end
