class UserOutboxMindmapProxy < RedisBaseProxy

  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_outbox_mindmaps"
  end

  def xxxs_ids_db
    Mindmap.of_user_id(@user.id).publics.find(:all,:limit=>100,:order=>'id desc').map{|x| x.id}
  end

  def self.remove_mindmap_cache(mindmap)
    user = mindmap.user
    return if user.blank?
    UserOutboxMindmapProxy.new(user).remove_from_cache(mindmap.id)
  end

  def self.add_mindmap_cache(mindmap)
    uomp = UserOutboxMindmapProxy.new(mindmap.user)
    ids = uomp.xxxs_ids
    unless ids.include?(mindmap.id)
      ids.unshift(mindmap.id)
      ids = ids[0..99] if ids.length > 100
      uomp.send(:xxxs_ids_rediscache_save,ids)
    end
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
      }
    }
  end

end
