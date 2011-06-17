class ViewpointVoteReputationProxy

  def self.add_viewpoint_vote_up(viewpoint_vote)
    return unless viewpoint_vote.is_vote_up?

    viewpoint = viewpoint_vote.viewpoint
    feed = viewpoint.feed
    user = viewpoint.user
    info = {:feed_id=>feed.id,:viewpoint_id=>viewpoint.id}

    ActiveRecord::Base.transaction do
      ReputationLog.create(:user=>user,:kind=>ReputationLog::ADD_VIEWPOINT_VOTE_UP,:info_json=>info.to_json)
      user.add_reputation(10)
    end
  end

  def self.cancel_viewpoint_vote_up(viewpoint_vote)
    return unless viewpoint_vote.is_vote_up?

    viewpoint = viewpoint_vote.viewpoint
    feed = viewpoint.feed
    user = viewpoint.user
    info = {:feed_id=>feed.id,:viewpoint_id=>viewpoint.id}

    ActiveRecord::Base.transaction do
      ReputationLog.create(:user=>user,:kind=>ReputationLog::CANCEL_VIEWPOINT_VOTE_UP,:info_json=>info.to_json)
      user.add_reputation(-10)
    end
  end

  def self.rules
    {
      :class => ViewpointVote,
      :after_create => Proc.new{|vv|
        # 观点 被投 赞成表
        if vv.is_vote_up?
          ViewpointVoteReputationProxy.add_viewpoint_vote_up(vv)
        end
      },
      :after_destroy => Proc.new{|vv|
        # 赞成表 被取消
        if vv.is_vote_up?
          ViewpointVoteReputationProxy.cancel_viewpoint_vote_up(vv)
        end
      }
    }
  end



  def self.funcs
    []
  end
end
