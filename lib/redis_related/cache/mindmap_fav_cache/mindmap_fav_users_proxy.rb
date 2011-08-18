class MindmapFavUsersProxy < RedisBaseProxy
  def initialize(mindmap)
    @mindmap = mindmap
    @key = "mindmap_#{mindmap.id}_fav_users"
  end

  def xxxs_ids_db
    @mindmap.fav_users_db.map{|user|user.id}
  end

  def self.rules
    {
      :class => MindmapFav ,
      :after_create => Proc.new {|mindmap_fav|
        mindmap = mindmap_fav.mindmap
        user = mindmap_fav.user
        next if mindmap.blank? || user.blank?
        MindmapFavUsersProxy.new(mindmap).add_to_cache(user.id)
      },
      :after_destroy => Proc.new {|mindmap_fav|
        mindmap = mindmap_fav.mindmap
        user = mindmap_fav.user
        next if mindmap.blank? || user.blank?
        MindmapFavUsersProxy.new(mindmap).remove_from_cache(user.id)
      }
    }
  end
  
  def self.funcs
    {
      :class => Mindmap,
      :fav_users => Proc.new{|mindmap|
        MindmapFavUsersProxy.new(mindmap).get_models(User)
      }
    }
  end
end
