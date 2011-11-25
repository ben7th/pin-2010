class UserPrivateMindmapProxy < RedisBaseProxy

  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_private_mindmaps"
  end

  def xxxs_ids_db
    @user.mindmaps.privacy.find(:all,:order=>'mindmaps.id desc').map{|x| x.id}
  end

  def self.remove_mindmap_cache(mindmap)
    user = mindmap.user
    return if user.blank?
    UserPrivateMindmapProxy.new(user).remove_from_cache(mindmap.id)
  end

  def self.add_mindmap_cache(mindmap)
    return unless mindmap.private?

    UserPrivateMindmapProxy.new(mindmap.user).add_to_cache(mindmap.id)
  end

  def self.rules
    {
      :class => Mindmap ,
      :after_create => Proc.new {|mindmap|
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
      },
      :private_mindmaps_paginate => Proc.new {|user,options|
        ids = UserPrivateMindmapProxy.new(user).xxxs_ids.paginate(options)

        mindmaps = ids.map{|id|Mindmap.find_by_id(id)}.compact
        ids.replace(mindmaps)
        ids
      }
    }
  end

end
