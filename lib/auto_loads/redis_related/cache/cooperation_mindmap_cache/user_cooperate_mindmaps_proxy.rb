class UserCooperateMindmapsProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{user.id}_cooperate_mindmaps"
  end

  def xxxs_ids_db
    @user.cooperate_mindmaps_db.map{|mindmap|mindmap.id}
  end

  def self.rules
    {
      :class => CooperationUser ,
      :after_create => Proc.new {|cooperation_user|
        user = cooperation_user.user
        mindmap = cooperation_user.mindmap
        next if user.blank? || mindmap.blank?
        UserCooperateMindmapsProxy.new(user).add_to_cache(mindmap.id)
      },
      :after_destroy => Proc.new {|cooperation_user|
        user = cooperation_user.user
        mindmap = cooperation_user.mindmap
        next if user.blank? || mindmap.blank?
        UserCooperateMindmapsProxy.new(user).remove_from_cache(mindmap.id)
      }
    }
  end
  
  def self.funcs
    {
      :class  => User ,
      :cooperate_mindmaps => Proc.new {|user|
        UserCooperateMindmapsProxy.new(user).get_models(Mindmap)
      }
    }
  end
end
