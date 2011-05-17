class UserTipProxy < BaseTipProxy
  FAVS_EDIT_FEED_CONTENT = "favs_edit_feed_content"
  FAVS_ADD_VIEWPOINT = "favs_add_viewpoint"
  FAVS_EDIT_VIEWPOINT = "favs_edit_viewpoint"
  FEED_INVITE = "feed_invite"
  VIEWPOINT_VOTE_UP = "viewpoint_vote_up"
  VIEWPOINT_SPAM_MARK_EFFECT = "viewpoint_spam_mark_effect"

  FEED_SPAM_MARK_EFFECT = "feed_spam_mark_effect"
  VIEWPOINT_COMMENT = "viewpoint_comment"


  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_tip"
    @rh = RedisHash.new(@key)
  end

  def tips_count
    @rh.all.keys.count
  end

  def tips
    tips = []
    @rh.all.each do |tip_id,tip_hash|
      case tip_hash["kind"]
      when FAVS_EDIT_FEED_CONTENT
        tip = build_favs_tip(tip_id,tip_hash)
        next if tip.blank?
        tips.push(tip)
      when FAVS_ADD_VIEWPOINT
        tip = build_favs_tip(tip_id,tip_hash)
        next if tip.blank?
        tips.push(tip)
      when FAVS_EDIT_VIEWPOINT
        tip = build_favs_tip(tip_id,tip_hash)
        next if tip.blank?
        tips.push(tip)
      when FEED_INVITE
        feed = Feed.find_by_id(tip_hash["feed_id"])
        creator = User.find_by_id(tip_hash["creator_id"])
        kind = tip_hash["kind"]
        time = Time.at(tip_hash["time"].to_f)
        next if feed.blank? || creator.blank?
        tip = Struct.new(:id,:feed,:creator,:kind,:time).new(tip_id,feed,creator,kind,time)
        tips.push(tip)
      when VIEWPOINT_VOTE_UP
        viewpoint = TodoUser.find_by_id(tip_hash["viewpoint_id"])
        voters_ids = tip_hash["voter_id"].to_s.split(",").uniq
        voters = voters_ids.map{|id|User.find_by_id(id)}.compact
        kind = tip_hash["kind"]
        time = Time.at(tip_hash["time"].to_f)
        next if voters.blank? || viewpoint.blank?
        tip = Struct.new(:id,:viewpoint,:voters,:kind,:time).new(tip_id,viewpoint,voters,kind,time)
        tips.push(tip)
      when VIEWPOINT_SPAM_MARK_EFFECT
        viewpoint = TodoUser.find_by_id(tip_hash["viewpoint_id"])
        feed = Feed.find_by_id(tip_hash["feed_id"])
        kind = tip_hash["kind"]
        time = Time.at(tip_hash["time"].to_f)
        next if feed.blank? || viewpoint.blank?
        tip = Struct.new(:id,:viewpoint,:feed,:kind,:time).new(tip_id,viewpoint,feed,kind,time)
        tips.push(tip)
      when FEED_SPAM_MARK_EFFECT
        feed = Feed.find_by_id(tip_hash["feed_id"])
        kind = tip_hash["kind"]
        time = Time.at(tip_hash["time"].to_f)
        next if feed.blank?
        tip = Struct.new(:id,:feed,:kind,:time).new(tip_id,feed,kind,time)
        tips.push(tip)
      when VIEWPOINT_COMMENT
        feed = Feed.find_by_id(tip_hash["feed_id"])
        viewpoint = TodoUser.find_by_id(tip_hash["viewpoint_id"])
        viewpoint_comment = TodoMemoComment.find_by_id(tip_hash["viewpoint_comment_id"])
        user = User.find_by_id(tip_hash["user_id"])
        kind = tip_hash["kind"]
        time = Time.at(tip_hash["time"].to_f)
        next if feed.blank? || viewpoint.blank? || viewpoint_comment.blank?
        tip = Struct.new(:id,:feed,:viewpoint,:viewpoint_comment,:user,:kind,:time).new(tip_id,feed,viewpoint,viewpoint_comment,user,kind,time)
        tips.push(tip)
      end
    end
    tips.sort{|a,b|b.time<=>a.time}
  end

  def build_favs_tip(tip_id,tip_hash)
    feed = Feed.find_by_id(tip_hash["feed_id"])
    user = User.find_by_id(tip_hash["user_id"])
    kind = tip_hash["kind"]
    time = Time.at(tip_hash["time"].to_f)
    return if feed.blank? || user.blank?
    Struct.new(:id,:feed,:user,:kind,:time).new(tip_id,feed,user,kind,time)
  end

  def create_favs_tip(kind,feed,operator)
    tip_id = randstr
    tip_hash = {"feed_id"=>feed.id,"user_id"=>operator.id,"kind"=>kind,"time"=>Time.now.to_f.to_s}
    @rh.set(tip_id,tip_hash)
  end

  def create_feed_invite_tip(feed,creator)
    tip_id = randstr
    tip_hash = {"feed_id"=>feed.id,"creator_id"=>creator.id,"kind"=>FEED_INVITE,"time"=>Time.now.to_f.to_s}
    @rh.set(tip_id,tip_hash)
  end

  def create_viewpoint_vote_up_tip(viewpoint,voter)
    tip_id = find_tip_id_by_viewpoint_id_on_viewpoint_vote_up_tip(viewpoint.id)
    if tip_id.blank?
      tip_id = randstr
      tip_hash = {"viewpoint_id"=>viewpoint.id,"voter_id"=>voter.id,"kind"=>VIEWPOINT_VOTE_UP,"time"=>Time.now.to_f.to_s}
    else
      tip_hash = @rh.get(tip_id)
      tip_hash["voter_id"] = tip_hash["voter_id"].to_s.split(",").push(voter.id).uniq*","
    end
    @rh.set(tip_id,tip_hash)
  end

  def find_tip_id_by_viewpoint_id_on_viewpoint_vote_up_tip(viewpoint_id)
    @rh.all.each do |tip_id,tip_hash|
      if tip_hash["viewpoint_id"] == viewpoint_id && tip_hash["kind"] == VIEWPOINT_VOTE_UP
        return tip_id
      end
    end
    return
  end

  def destroy_feed_invite_tip(feed,creator)
    @rh.all.each do |tip_id,tip_hash|
      if tip_hash["kind"] == FEED_INVITE && tip_hash["feed_id"].to_s == feed.id.to_s && tip_hash["creator_id"].to_s == creator.id.to_s
        return remove_tip_by_tip_id(tip_id)
      end
    end
  end
  
  def destroy_viewpoint_vote_up_tip(viewpoint,voter)
    tip_id = find_tip_id_by_viewpoint_id_on_viewpoint_vote_up_tip(viewpoint.id)
    return if tip_id.blank?
    tip_hash = @rh.get(tip_id)
    if tip_hash["voter_id"].to_s.split(",").uniq == [voter.id.to_s]
      remove_tip_by_tip_id(tip_id)
    else
      voters_ids = tip_hash["voter_id"].to_s.split(",")
      voters_ids.delete(voter.id.to_s)
      tip_hash["voter_id"] = voters_ids*","
      @rh.set(tip_id,tip_hash)
    end
  end

  def create_viewpoint_spam_mark_effect_tip(viewpoint)
    feed = viewpoint.feed
    tip_id = randstr

    tip_hash = {"feed_id"=>feed.id,"viewpoint_id"=>viewpoint.id,"kind"=>VIEWPOINT_SPAM_MARK_EFFECT,"time"=>Time.now.to_f.to_s}
    @rh.set(tip_id,tip_hash)
  end

  def create_feed_spam_mark_effect_tip(feed)
    tip_id = randstr

    tip_hash = {"feed_id"=>feed.id,"kind"=>FEED_SPAM_MARK_EFFECT,"time"=>Time.now.to_f.to_s}
    @rh.set(tip_id,tip_hash)
  end

  def create_viewpoint_comment_tip(viewpoint_comment)
    user = viewpoint_comment.user
    viewpoint = viewpoint_comment.todo_user
    feed = viewpoint.feed
    tip_id = randstr

    tip_hash = {"feed_id"=>feed.id,"viewpoint_id"=>viewpoint.id,
      "viewpoint_comment_id"=>viewpoint_comment.id,"user_id"=>user.id,
      "kind"=>VIEWPOINT_COMMENT,"time"=>Time.now.to_f.to_s}
    @rh.set(tip_id,tip_hash)
  end

  def self.rules
    [
      {
        :class => FeedChange,
        :after_create => Proc.new{|feed_change|
          UserTipProxy.create_favs_edit_feed_content_tip_on_queue(feed_change)
        }
      },
      {
        :class => TodoUser,
        :after_create => Proc.new{|todo_user|
          UserTipProxy.create_favs_add_viewpoint_tip_on_queue(todo_user)
        },
        :after_update => Proc.new{|todo_user|
          UserTipProxy.create_fav_edit_viewpoint_tip_on_queue(todo_user)
        }
      },
      {
        :class => FeedInvite,
        :after_create => Proc.new{|feed_invite|
          UserTipProxy.create_feed_invite_tip_on_queue(feed_invite)
        },
        :after_destroy => Proc.new{|feed_invite|
          UserTipProxy.destroy_feed_invite_tip(feed_invite)
        }
      },
      {
        :class => ViewpointVote,
        :after_create => Proc.new{|viewpoint_vote|
          UserTipProxy.create_viewpoint_vote_up_tip_on_queue(viewpoint_vote) if viewpoint_vote.is_vote_up?
        },
        :after_destroy => Proc.new{|viewpoint_vote|
          UserTipProxy.destroy_viewpoint_vote_up_tip(viewpoint_vote) if viewpoint_vote.is_vote_up?
        }
      },
      {
        :class => ViewpointSpamMark,
        :after_create => Proc.new{|vsm|
          viewpoint = vsm.viewpoint
          if viewpoint.spam_mark_effect?
            UserTipProxy.create_viewpoint_spam_mark_effect_tip_on_queue(viewpoint)
          end
        }
      },
      {
        :class => SpamMark,
        :after_create => Proc.new{|sm|
          feed = sm.feed
          if feed.spam_mark_effect?
            UserTipProxy.create_feed_spam_mark_effect_tip_on_queue(feed)
          end
        }
      },
      {
        :class => TodoMemoComment,
        :after_create => Proc.new{|tc|
          UserTipProxy.create_viewpoint_comment_tip_on_queue(tc)
        }
      }
    ]
  end

  extend QueueMethods
end
