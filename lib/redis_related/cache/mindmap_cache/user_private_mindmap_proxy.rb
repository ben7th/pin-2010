class UserPrivateMindmapProxy < RedisBaseProxy

  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_private_mindmaps"
  end

  def xxxs_ids_db
    Mindmap.of_user_id(@user.id).privacy.find(:all,:limit=>100,:order=>'id desc').map{|x| x.id}
  end

  def self.remove_mindmap_cache(mindmap)
    user = mindmap.user
    return if user.blank?
    UserPrivateMindmapProxy.new(user).remove_from_cache(mindmap.id)
  end

  def self.add_mindmap_cache(mindmap)
    upmp = UserPrivateMindmapProxy.new(mindmap.user)
    ids = upmp.xxxs_ids
    unless ids.include?(mindmap.id)
      ids.unshift(mindmap.id)
      ids = ids[0..99] if ids.length > 100
      upmp.send(:xxxs_ids_rediscache_save,ids)
    end
  end

  def self.rules
    {
      :class => Mindmap ,
      :after_create => Proc.new {|mindmap|
        next unless mindmap.private?
        UserPrivateMindmapProxy.add_mindmap_cache(mindmap)
      },
      :after_update => Proc.new {|mindmap|
        if mindmap.private?
          UserPrivateMindmapProxy.add_mindmap_cache(mindmap)
        else
          UserPrivateMindmapProxy.remove_mindmap_cache(mindmap)
        end
      },
      :after_destroy => Proc.new {|mindmap|
        UserPrivateMindmapProxy.remove_mindmap_cache(mindmap)
      }
    }
  end


  def self.funcs
    {
      :class => User ,
      :private_mindmaps => Proc.new{|user|
        UserPrivateMindmapProxy.new(user).get_models(Mindmap)
      },
      :private_mindmap_ids => Proc.new{|user|
        UserPrivateMindmapProxy.new(user).xxxs_ids
      }
    }
  end

end
