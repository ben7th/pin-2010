module FavsAddPostMethods
  def self.included(base)
    base.extend ClassMethods
    base.add_rules({
        :class => Post,
        :after_create => Proc.new{|post|
          UserTipProxy.create_favs_add_post_tip_on_queue(post)
        },
        :after_update => Proc.new{|post|
          next if post.changes["memo"].blank?
          UserTipProxy.create_fav_edit_post_tip_on_queue(post)
        }
      })
  end

  module ClassMethods
    # 在 队列中 增加 收藏的话题有新观点 提示
    def create_favs_add_post_tip_on_queue(post)
      UserTipResqueQueueWorker.async_user_tip(UserTipProxy::FAVS_ADD_POST,[post.id])
    end

    # 收藏的话题有新观点
    def create_favs_add_post_tip(post)
      feed = post.feed
      operator = post.user
      self.create_favs_tip(UserTipProxy::FAVS_ADD_POST,feed,operator)
    end
  end
end
