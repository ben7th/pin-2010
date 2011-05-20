module ViewpointCommentMethods
  def self.included(base)
    base.extend ClassMethods
    base.add_rules({
        :class => TodoMemoComment,
        :after_create => Proc.new{|tc|
          UserTipProxy.create_viewpoint_comment_tip_on_queue(tc)
        }
      })
  end

  def create_viewpoint_comment_tip(viewpoint_comment)
    user = viewpoint_comment.user
    viewpoint = viewpoint_comment.todo_user
    feed = viewpoint.feed
    tip_id = randstr

    tip_hash = {"feed_id"=>feed.id,"viewpoint_id"=>viewpoint.id,
      "viewpoint_comment_id"=>viewpoint_comment.id,"user_id"=>user.id,
      "kind"=>UserTipProxy::VIEWPOINT_COMMENT,"time"=>Time.now.to_f.to_s}
    @rh.set(tip_id,tip_hash)
  end

  module ClassMethods
    # 在 队列中 增加 观点讨论 提示
    def create_viewpoint_comment_tip_on_queue(tc)
      UserTipResqueQueueWorker.async_user_tip(UserTipProxy::VIEWPOINT_COMMENT,[tc.id])
    end

    def create_viewpoint_comment_tip(viewpoint_comment)
      UserTipProxy.new(viewpoint_comment.todo_user.user).create_viewpoint_comment_tip(viewpoint_comment)
    end
  end
end
