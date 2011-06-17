class FeedVoteReputationProxy

  def self.add_feed_vote_up(feed_vote)
    return unless feed_vote.is_vote_up?

    feed = feed_vote.feed
    user = feed.creator
    info = {:feed_id=>feed.id}

    ActiveRecord::Base.transaction do
      ReputationLog.create(:user=>user,:kind=>ReputationLog::ADD_FEED_VOTE_UP,:info_json=>info.to_json)
      user.add_reputation(5)
    end
  end

  def self.cancel_feed_vote_up(feed_vote)
    return unless feed_vote.is_vote_up?

    feed = feed_vote.feed
    user = feed.creator
    info = {:feed_id=>feed.id}

    ActiveRecord::Base.transaction do
      ReputationLog.create(:user=>user,:kind=>ReputationLog::CANCEL_FEED_VOTE_UP,:info_json=>info.to_json)
      user.add_reputation(-5)
    end
  end


  def self.rules
    {
      :class => FeedVote,
      :after_create => Proc.new{|fv|
        # 主题 被投 赞成表
        if fv.is_vote_up?
          FeedVoteReputationProxy.add_feed_vote_up(fv)
        end
      },
      :after_destroy => Proc.new{|fv|
        # 赞成票 被取消
        if fv.is_vote_up?
          FeedVoteReputationProxy.cancel_feed_vote_up(fv)
        end
      }
    }
  end

  def self.funcs
    []
  end
end
