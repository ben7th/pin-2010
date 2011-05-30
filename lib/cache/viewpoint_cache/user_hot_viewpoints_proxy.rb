class UserHotViewpointsProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_hot_viewpoints"
  end

  def xxxs_ids_db
    @user.top_viewpoints_db.map{|viewpoint|viewpoint.id}
  end

  def self.add_to_cache_when_not_include(viewpoint)
    return unless viewpoint.vote_score > 0
    uhvp = UserHotViewpointsProxy.new(viewpoint.user)
    ids = uhvp.xxxs_ids
    unless ids.include?(viewpoint.id)
      ids.unshift(viewpoint.id)
      uhvp.send(:xxxs_ids_rediscache_save,ids)
    end
  end

  def self.remove_from_cache_when_include(viewpoint)
    uhvp = UserHotViewpointsProxy.new(viewpoint.user)
    ids = uhvp.xxxs_ids
    if ids.include?(viewpoint.id)
      ids.delete(viewpoint.id)
      uhvp.send(:xxxs_ids_rediscache_save,ids)
    end
  end

  def self.refresh_cache_on_edit_viewpoint(viewpoint)
    feed = viewpoint.feed
    if feed.hot_viewpoint == viewpoint
      uhvp = UserHotViewpointsProxy.new(viewpoint.user)
      ids = uhvp.xxxs_ids
      ids.delete(viewpoint.id)
      ids.unshift(viewpoint.id)
      uhvp.send(:xxxs_ids_rediscache_save,ids)
    end
  end

  def self.refresh_cache_on_viewpoint_vote(viewpoint)
    feed = viewpoint.feed
    if feed.hot_viewpoint == viewpoint
      
        UserHotViewpointsProxy.add_to_cache_when_not_include(viewpoint)

        second_viewpoint = feed.viewpoints[1]
        if !second_viewpoint.blank?
          UserHotViewpointsProxy.remove_from_cache_when_include(second_viewpoint)
        end

    else
      
        UserHotViewpointsProxy.remove_from_cache_when_include(viewpoint)

        hot_viewpoint = feed.hot_viewpoint
        unless hot_viewpoint.blank?
          UserHotViewpointsProxy.add_to_cache_when_not_include(hot_viewpoint)
        end
        
    end
  end

  def self.rules
    {
      :class => Viewpoint,
      :after_update => Proc.new {|viewpoint|
        if !viewpoint.changes["memo"].blank?
          UserHotViewpointsProxy.refresh_cache_on_edit_viewpoint(viewpoint)
        elsif !viewpoint.changes["vote_score"].blank?
          UserHotViewpointsProxy.refresh_cache_on_viewpoint_vote(viewpoint)
        end
      }
    }
  end

  def self.funcs
    {
      :class => User,
      :top_viewpoints => Proc.new{|user|
        UserHotViewpointsProxy.new(user).get_models(Viewpoint)
      }
    }
  end
end
