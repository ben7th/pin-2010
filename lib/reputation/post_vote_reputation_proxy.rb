class PostVoteReputationProxy

  def self.add_post_vote_up(post_vote)
    return unless post_vote.is_vote_up?

    post = post_vote.post
    feed = post.feed
    user = post.user
    info = {:feed_id=>feed.id,:post_id=>post.id}

    ActiveRecord::Base.transaction do
      ReputationLog.create(:user=>user,:kind=>ReputationLog::ADD_POST_VOTE_UP,:info_json=>info.to_json)
      user.add_reputation(10)
    end
  end

  def self.cancel_post_vote_up(post_vote)
    return unless post_vote.is_vote_up?

    post = post_vote.post
    feed = post.feed
    user = post.user
    info = {:feed_id=>feed.id,:post_id=>post.id}

    ActiveRecord::Base.transaction do
      ReputationLog.create(:user=>user,:kind=>ReputationLog::CANCEL_POST_VOTE_UP,:info_json=>info.to_json)
      user.add_reputation(-10)
    end
  end

  def self.rules
    {
      :class => PostVote,
      :after_create => Proc.new{|vv|
        # 观点 被投 赞成表
        if vv.is_vote_up?
          PostVoteReputationProxy.add_post_vote_up(vv)
        end
      },
      :after_destroy => Proc.new{|vv|
        # 赞成表 被取消
        if vv.is_vote_up?
          PostVoteReputationProxy.cancel_post_vote_up(vv)
        end
      }
    }
  end



  def self.funcs
    []
  end
end
