class UserOutCollectionProxy < RedisBaseProxy

  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_out_collections"
  end

  def xxxs_ids_db
    @user.out_collections_db.map{|x| x.id}
  end

  def self.remove_collection_cache(collection)
    creator = collection.creator
    return if creator.blank?
    UserOutCollectionProxy.new(creator).remove_from_cache(collection.id)
  end

  def self.add_collection_cache(collection)
    return unless collection.public?

    creator = collection.creator
    return if creator.blank?

    proxy = UserOutCollectionProxy.new(creator)
    ids = proxy.xxxs_ids
    unless ids.include?(collection.id)
      proxy.add_to_cache(collection.id)
    end
  end

  def self.rules
    {
      :class => Collection ,
      :after_create => Proc.new {|collection|
        UserOutCollectionProxy.add_collection_cache(collection)
      },
      :after_update => Proc.new{|collection|
        if collection.public?
          UserOutCollectionProxy.add_collection_cache(collection)
        else
          UserOutCollectionProxy.remove_collection_cache(collection)
        end
      },
      :after_destroy => Proc.new {|collection|
        UserOutCollectionProxy.remove_collection_cache(collection)
      }
    }
  end

  def self.funcs
    {
      :class=>User,
      :out_collections=>Proc.new{|user|
        UserOutCollectionProxy.new(user).get_models(Collection)
      }
    }
  end
  
end
