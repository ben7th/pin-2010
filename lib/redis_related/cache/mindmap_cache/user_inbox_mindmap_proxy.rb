class UserInboxMindmapProxy < RedisBaseProxy

  def initialize(user)
    @user = user
  end

  def xxxs_ids_db
    id_list_from_followings_and_self_newer_than(nil)
  end

  def id_list_from_followings_and_self_newer_than(newest_id)
    _id_list = @user.followings_and_self.map{|user|
      UserOutboxMindmapProxy.new(user).xxxs_ids
    }.flatten
    _id_private = @user.private_mindmap_ids
    # 排序，大的就是新的，排在前面
    ids = (_id_list+_id_private).sort{|x,y| y<=>x}

    if !newest_id.nil?
      ids = ids.compact.select{|x| x > newest_id}
    end

    ids[0..199]
  end

  def xxxs_ids
    xxxs_ids_db
  end

  def self.rules
    []
  end

  def self.funcs
    {
      :class  => User ,
      :in_mindmaps => Proc.new {|user|
        UserInboxMindmapProxy.new(user).get_models(Mindmap)
      },
      :in_mindmaps_paginate => Proc.new {|user,options|
        ids = UserInboxMindmapProxy.new(user).xxxs_ids.paginate(options)
        mindmaps = ids.map{|id|Mindmap.find_by_id(id)}.compact
        ids.replace(mindmaps)
        ids
      }
    }
  end
end