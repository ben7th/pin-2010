=begin
      key user_xx_viewpint_vote_up_tip
      value {
              "#{randstr}"=>{"voter_id"=>"1,2","viewpoint_id"=>"","time"=>""},
              "#{randstr}"=>{"voter_id"=>"","viewpoint_id"=>"","time"=>""}
            }
=end
class UserViewpointVoteUpTipProxy < BaseTipProxy
  definition_tip_attrs :id,:viewpoint,:voters,:time
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_viewpint_vote_up_tip"
    @rh = RedisHash.new(@key)
  end

  def tips
    tips = []
    @rh.all.each do |tip_id,tip_hash|
      viewpoint = TodoUser.find_by_id(tip_hash["viewpoint_id"])
      voters_ids = tip_hash["voter_id"].to_s.split(",").uniq
      voters = voters_ids.map{|id|User.find_by_id(id)}.compact
      time = Time.at(tip_hash["time"].to_f)
      next if voters.blank? || viewpoint.blank?
      tips.push(UserViewpointVoteUpTipProxy::Tip.new(tip_id,viewpoint,voters,time))
    end
    tips
  end

  def add_tip(viewpoint,voter)
    tip_id = find_tip_id_by_viewpoint_id(viewpoint.id)
    if tip_id.blank?
      tip_id = randstr
      tip_hash = {"viewpoint_id"=>viewpoint.id,"voter_id"=>voter.id,"time"=>Time.now.to_f.to_s}
    else
      tip_hash = @rh.get(tip_id)
      tip_hash["voter_id"] = tip_hash["voter_id"].to_s.split(",").push(voter.id).uniq*","
    end
    @rh.set(tip_id,tip_hash)
  end

  def remove_tip(viewpoint,voter)
    tip_id = find_tip_id_by_viewpoint_id(viewpoint.id)
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

  def find_tip_id_by_viewpoint_id(viewpoint_id)
    @rh.all.each do |tip_id,tip_hash|
      if tip_hash["viewpoint_id"] == viewpoint_id
        return tip_id
      end
    end
    return
  end
  
  class << self
    def add_tip(viewpoint_vote)
      viewpoint = viewpoint_vote.viewpoint
      voter = viewpoint_vote.user
      self.new(viewpoint.user).add_tip(viewpoint,voter)
    end

    def remove_tip(viewpoint_vote)
      viewpoint = viewpoint_vote.viewpoint
      voter = viewpoint_vote.user
      self.new(viewpoint.user).remove_tip(viewpoint,voter)
    end

    def rules
      {
        :class => ViewpointVote,
        :after_create => Proc.new{|viewpoint_vote|
          UserViewpointVoteUpTipProxy.add_tip(viewpoint_vote) if viewpoint_vote.is_vote_up?
        },
        :after_destroy => Proc.new{|viewpoint_vote|
          UserViewpointVoteUpTipProxy.remove_tip(viewpoint_vote) if viewpoint_vote.is_vote_up?
        }
      }
    end
  end

end
