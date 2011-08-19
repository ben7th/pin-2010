module FavsEditPostMethods
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    # 在 队列中 增加 收藏的话题的观点被修改 提示
    def create_fav_edit_post_tip_on_queue(post)
      UserTipResqueQueueWorker.async_user_tip(UserTipProxy::FAVS_EDIT_POST,[post.id])
    end

    # 收藏的话题的观点被修改
    def create_fav_edit_post_tip(post)
      feed = post.feed
      operator = post.user
      self.create_favs_tip(UserTipProxy::FAVS_EDIT_POST,feed,operator)
    end
  end
    
end
