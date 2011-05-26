class UserHotViewpointsProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_hot_viewpoints"
  end

  def xxxs_ids_db
    @user.top_viewpoints_db.map{|viewpoint|viewpoint.id}
  end

  def self.add_to_cache_when_not_include(todo_user)
    return unless todo_user.vote_score > 0
    uhvp = UserHotViewpointsProxy.new(todo_user.user)
    ids = uhvp.xxxs_ids
    unless ids.include?(todo_user.id)
      ids.unshift(todo_user.id)
      uhvp.send(:xxxs_ids_rediscache_save,ids)
    end
  end

  def self.remove_from_cache_when_include(todo_user)
    uhvp = UserHotViewpointsProxy.new(todo_user.user)
    ids = uhvp.xxxs_ids
    if ids.include?(todo_user.id)
      ids.delete(todo_user.id)
      uhvp.send(:xxxs_ids_rediscache_save,ids)
    end
  end

  def self.refresh_cache_on_edit_viewpoint(todo_user)
    feed = todo_user.feed
    if feed.hot_viewpoint == todo_user
      uhvp = UserHotViewpointsProxy.new(todo_user.user)
      ids = uhvp.xxxs_ids
      ids.delete(todo_user.id)
      ids.unshift(todo_user.id)
      uhvp.send(:xxxs_ids_rediscache_save,ids)
    end
  end

  def self.refresh_cache_on_viewpoint_vote(todo_user)
    feed = todo_user.feed
    if feed.hot_viewpoint == todo_user
      
        UserHotViewpointsProxy.add_to_cache_when_not_include(todo_user)

        second_viewpoint = feed.viewpoints[1]
        if !second_viewpoint.blank?
          UserHotViewpointsProxy.remove_from_cache_when_include(second_viewpoint)
        end

    else
      
        UserHotViewpointsProxy.remove_from_cache_when_include(todo_user)

        hot_viewpoint = feed.hot_viewpoint
        unless hot_viewpoint.blank?
          UserHotViewpointsProxy.add_to_cache_when_not_include(hot_viewpoint)
        end
        
    end
  end

  def self.rules
    {
      :class => TodoUser,
      :after_update => Proc.new {|todo_user|
        if !todo_user.changes["memo"].blank?
          UserHotViewpointsProxy.refresh_cache_on_edit_viewpoint(todo_user)
        elsif !todo_user.changes["vote_score"].blank?
          UserHotViewpointsProxy.refresh_cache_on_viewpoint_vote(todo_user)
        end
      }
    }
  end

  def self.funcs
    {
      :class => User,
      :top_viewpoints => Proc.new{|user|
        UserHotViewpointsProxy.new(user).get_models(TodoUser)
      }
    }
  end
end
