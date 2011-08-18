module FavsEditViewpointMethods
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    # 在 队列中 增加 收藏的话题的观点被修改 提示
    def create_fav_edit_viewpoint_tip_on_queue(viewpoint)
      UserTipResqueQueueWorker.async_user_tip(UserTipProxy::FAVS_EDIT_VIEWPOINT,[viewpoint.id])
    end

    # 收藏的话题的观点被修改
    def create_fav_edit_viewpoint_tip(viewpoint)
      feed = viewpoint.feed
      operator = viewpoint.user
      self.create_favs_tip(UserTipProxy::FAVS_EDIT_VIEWPOINT,feed,operator)
    end
  end
    
end
