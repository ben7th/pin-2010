module PostCommentMethods
  def self.included(base)
    base.extend ClassMethods
    base.add_rules({
        :class => PostComment,
        :after_create => Proc.new{|tc|
          next if tc.user == tc.post.user
          UserTipProxy.create_post_comment_tip_on_queue(tc)
        }
      })
  end

  def create_post_comment_tip(post_comment)
    user = post_comment.user
    post = post_comment.post
    feed = post.feed
    tip_id = randstr

    tip_hash = {"feed_id"=>feed.id,"post_id"=>post.id,
      "post_comment_id"=>post_comment.id,"user_id"=>user.id,
      "kind"=>UserTipProxy::POST_COMMENT,"time"=>Time.now.to_f.to_s}
    @rh.set(tip_id,tip_hash)
  end

  module ClassMethods
    # 在 队列中 增加 观点讨论 提示
    def create_post_comment_tip_on_queue(tc)
      UserTipResqueQueueWorker.async_user_tip(UserTipProxy::POST_COMMENT,[tc.id])
    end

    def create_post_comment_tip(post_comment)
      UserTipProxy.new(post_comment.post.user).create_post_comment_tip(post_comment)
    end
  end
end
