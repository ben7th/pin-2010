class UserFavMindmapsProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{user.id}_fav_mindmaps"
  end

  def xxxs_ids_db
    @user.fav_mindmaps_db.map{|mindmap|mindmap.id}
  end

  def self.rules
    {
      :class => MindmapFav ,
      :after_create => Proc.new {|mindmap_fav|
        mindmap = mindmap_fav.mindmap
        user = mindmap_fav.user
        next if mindmap.blank? || user.blank?
        UserFavMindmapsProxy.new(user).add_to_cache(mindmap.id)
      },
      :after_destroy => Proc.new {|mindmap_fav|
        mindmap = mindmap_fav.mindmap
        user = mindmap_fav.user
        next if mindmap.blank? || user.blank?
        UserFavMindmapsProxy.new(user).remove_from_cache(mindmap.id)
      }
    }
  end

  def self.funcs
    {
      :class  => User ,
      :fav_mindmaps => Proc.new {|user|
        UserFavMindmapsProxy.new(user).get_models(Mindmap)
      },
      :fav_mindmaps_paginate => Proc.new {|user,options|
        ids = UserFavMindmapsProxy.new(user).xxxs_ids.paginate(options)
        mindmaps = ids.map{|id|Mindmap.find_by_id(id)}.compact
        ids.replace(mindmaps)
        ids
      }
    }
  end
end
