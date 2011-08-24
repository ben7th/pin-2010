class UserOutboxMindmapProxy < RedisBaseProxy

  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_outbox_mindmaps"
  end

  def xxxs_ids_db
    @user.mindmaps.publics.find(:all,:order=>'mindmaps.id desc').map{|x| x.id}
  end

  def self.remove_mindmap_cache(mindmap)
    user = mindmap.user
    return if user.blank?
    UserOutboxMindmapProxy.new(user).remove_from_cache(mindmap.id)
  end

  def self.add_mindmap_cache(mindmap)
    return if mindmap.private?
    return if mindmap.user.blank?
    
    UserOutboxMindmapProxy.new(mindmap.user).add_to_cache(mindmap.id)
  end

  def self.rules
    {
      :class => Mindmap ,
      :after_create => Proc.new {|mindmap|
        UserOutboxMindmapProxy.add_mindmap_cache(mindmap)
      },
      :after_update => Proc.new {|mindmap|
        if mindmap.private?
          UserOutboxMindmapProxy.remove_mindmap_cache(mindmap)
        else
          UserOutboxMindmapProxy.add_mindmap_cache(mindmap)
        end
      },
      :after_destroy => Proc.new {|mindmap|
        UserOutboxMindmapProxy.remove_mindmap_cache(mindmap)
      }
    }
  end


  def self.funcs
    {
      :class => User ,
      :out_mindmaps => Proc.new{|user|
        UserOutboxMindmapProxy.new(user).get_models(Mindmap)
      },
      :out_mindmaps_paginate => Proc.new {|user,options|
        ids = UserOutboxMindmapProxy.new(user).xxxs_ids.paginate(options)

        mindmaps = ids.map{|id|Mindmap.find_by_id(id)}.compact
        ids.replace(mindmaps)
        ids
      }
    }
  end

end
