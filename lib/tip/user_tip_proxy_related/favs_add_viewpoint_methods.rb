module FavsAddViewpointMethods
  def self.included(base)
    base.extend ClassMethods
    base.add_rules({
        :class => Viewpoint,
        :after_create => Proc.new{|viewpoint|
          UserTipProxy.create_favs_add_viewpoint_tip_on_queue(viewpoint)
        },
        :after_update => Proc.new{|viewpoint|
          next if viewpoint.changes["memo"].blank?
          UserTipProxy.create_fav_edit_viewpoint_tip_on_queue(viewpoint)
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
