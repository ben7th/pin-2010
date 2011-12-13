module UserHomeTimelineCollectionsCacheModule

  class CollectionsProxy < RedisBaseProxy
    
    def initialize(user)
      @user = user
      @key = "user_#{@user.id}_home_timeline_collections"
    end

    def xxxs_ids_db
      ids = []

      # 自己创建的收集册
      ids += @user.created_collections.map{|c| c.id}

      # 每个联系人的公开收集册
      @user.followings.map{|user|
        ids += user.public_collections.map{|c| c.id} # TODO 12月14日务必重构一次
      }

      ids.uniq.sort{|x,y| y<=>x}
    end

    def xxxs_ids
      xxxs_ids_db # 每次都重新查询，不缓存
    end
    
  end

  class LogicRules
    def self.rules
      [] # 不缓存所以无规则
    end

    def self.funcs
      {
        :class=>User,
        :home_timeline_collections=>Proc.new{|user|
          CollectionsProxy.new(user).get_models(Collection)
        }
      }
    end
  end
    
end
