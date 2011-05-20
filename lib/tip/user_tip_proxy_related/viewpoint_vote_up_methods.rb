module ViewpointVoteUpMethods
  def self.included(base)
    base.extend ClassMethods
    base.add_rules({
        :class => ViewpointVote,
        :after_create => Proc.new{|viewpoint_vote|
          UserTipProxy.create_viewpoint_vote_up_tip_on_queue(viewpoint_vote) if viewpoint_vote.is_vote_up?
        },
        :after_destroy => Proc.new{|viewpoint_vote|
          UserTipProxy.destroy_viewpoint_vote_up_tip(viewpoint_vote) if viewpoint_vote.is_vote_up?
        }
      })
  end

  def create_viewpoint_vote_up_tip(viewpoint,voter)
    tip_id = find_tip_id_by_hash({"viewpoint_id"=>viewpoint.id,"kind"=>UserTipProxy::VIEWPOINT_VOTE_UP})
    if tip_id.blank?
      tip_id = randstr
      tip_hash = {"viewpoint_id"=>viewpoint.id,"voter_id"=>voter.id,"kind"=>UserTipProxy::VIEWPOINT_VOTE_UP,"time"=>Time.now.to_f.to_s}
    else
      tip_hash = @rh.get(tip_id)
      tip_hash["voter_id"] = tip_hash["voter_id"].to_s.split(",").push(voter.id).uniq*","
      tip_hash["time"] = Time.now.to_f.to_s
    end
    @rh.set(tip_id,tip_hash)
  end

  def destroy_viewpoint_vote_up_tip(viewpoint,voter)
    tip_id = find_tip_id_by_hash({"viewpoint_id"=>viewpoint.id,"kind"=>UserTipProxy::VIEWPOINT_VOTE_UP})
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

  module ClassMethods
    # 在 队列中 增加 发表的观点被赞同 提示
    def create_viewpoint_vote_up_tip_on_queue(viewpoint_vote)
      UserTipResqueQueueWorker.async_user_tip(UserTipProxy::VIEWPOINT_VOTE_UP,[viewpoint_vote.id])
    end

    # 发表的观点被赞同
    def create_viewpoint_vote_up_tip(viewpoint_vote)
      viewpoint = viewpoint_vote.viewpoint
      voter = viewpoint_vote.user

      UserTipProxy.new(viewpoint.user).create_viewpoint_vote_up_tip(viewpoint,voter)
    end

    def destroy_viewpoint_vote_up_tip(viewpoint_vote)
      viewpoint = viewpoint_vote.viewpoint
      voter = viewpoint_vote.user
      self.new(viewpoint.user).destroy_viewpoint_vote_up_tip(viewpoint,voter)
    end
  end
end
