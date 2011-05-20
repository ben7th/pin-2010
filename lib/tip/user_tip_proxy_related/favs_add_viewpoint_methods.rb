module FavsAddViewpointMethods
  def self.included(base)
    base.extend ClassMethods
    base.add_rules({
        :class => TodoUser,
        :after_create => Proc.new{|todo_user|
          UserTipProxy.create_favs_add_viewpoint_tip_on_queue(todo_user)
        },
        :after_update => Proc.new{|todo_user|
          next if todo_user.changes["memo"].blank?
          UserTipProxy.create_fav_edit_viewpoint_tip_on_queue(todo_user)
        }
      })
  end

  module ClassMethods
    # 在 队列中 增加 收藏的话题有新观点 提示
    def create_favs_add_viewpoint_tip_on_queue(viewpoint)
      UserTipResqueQueueWorker.async_user_tip(UserTipProxy::FAVS_ADD_VIEWPOINT,[viewpoint.id])
    end

    # 收藏的话题有新观点
    def create_favs_add_viewpoint_tip(viewpoint)
      feed = viewpoint.feed
      operator = viewpoint.user
      self.create_favs_tip(UserTipProxy::FAVS_ADD_VIEWPOINT,feed,operator)
    end
  end
end
