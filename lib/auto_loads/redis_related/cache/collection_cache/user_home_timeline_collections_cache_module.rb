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

  end

  class LogicRules
    def self.rules
      {
        :class=>Collection,
        :after_save=>Proc.new{|collection|
          creator = collection.creator
          fans = creator.fans

          # 增加到创建者的 时间线
          CollectionsProxy.new(creator).add_to_cache(collection.id)

          # 如果是公开的，增加到 fan 的时间线
          # 如果是私有的，从 fan 时间线 删除

          if collection.public?
            fans.each do |fan|
              CollectionsProxy.new(fan).add_to_cache(collection.id)
            end
          else
            fans.each do |fan|
              CollectionsProxy.new(fan).remove_form_cache(collection.id)
            end
          end
        },
        :after_destroy=>Proc.new{|collection|
          creator = collection.creator
          fans = creator.fans
          
          # 从 创建者 时间线删除
          CollectionsProxy.new(creator).remove_from_cache(collection.id)

          # 从 fans 时间线 删除
          fans.each do |fan|
            CollectionsProxy.new(fan).remove_form_cache(collection.id)
          end
        }
      }
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
