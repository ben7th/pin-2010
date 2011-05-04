=begin
      key user_xx_viewpint_vote_up_tip
      value {
              "#{randstr}"=>{"voter_id"=>"1,2","viewpoint_id"=>"","time"=>""},
              "#{randstr}"=>{"voter_id"=>"","viewpoint_id"=>"","time"=>""}
            }
=end
class UserViewpointVoteUpTipProxy
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
      tips.push(UserViewpointVoteUpTip.new(tip_id,viewpoint,voters,time))
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
    mup_ap @rh.all
    tip_id = find_tip_id_by_viewpoint_id(viewpoint.id)
    return if tip_id.blank?
    tip_hash = @rh.get(tip_id)
    if tip_hash["voter_id"].to_s.split(",").uniq == [voter.id.to_s]
      mup_ap 1
      remove_tip_by_tip_id(tip_id)
    else
      mup_ap 2
      voters_ids = tip_hash["voter_id"].to_s.split(",")
      voters_ids.delete(voter.id.to_s)
      tip_hash["voter_id"] = voters_ids*","
      @rh.set(tip_id,tip_hash)
    end
    mup_ap @rh.all
  end

  def remove_all_tips
    @rh.del
  end

  def remove_tip_by_tip_id(tip_id)
    @rh.remove(tip_id)
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

  end

  class UserViewpointVoteUpTip
    attr_reader :id,:viewpoint,:voters,:time
    def initialize(id,viewpoint,voters,time)
      @id,@viewpoint,@voters,@time = id,viewpoint,voters,time
    end
  end

  module ViewpointVoteMethods
    def self.included(base)
      base.after_create :add_vote_up_tip
      base.after_destroy :remove_vote_up_tip
    end

    def add_vote_up_tip
      UserViewpointVoteUpTipProxy.add_tip(self) if self.is_vote_up?
      return true
    end

    def remove_vote_up_tip
      UserViewpointVoteUpTipProxy.remove_tip(self) if self.is_vote_up?
      return true
    end
  end
end
