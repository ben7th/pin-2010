class UserCreatedCollectionProxy < RedisBaseProxy

  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_created_collections"
  end

  def xxxs_ids_db
    @user.created_collections_db.map{|x|x.id}
  end
  
  def self.remove_collection_cache(collection)
    creator = collection.creator
    return if creator.blank?
    UserCreatedCollectionProxy.new(creator).remove_from_cache(collection.id)
  end

  def self.add_collection_cache(collection)
    creator = collection.creator
    return if creator.blank?

    proxy = UserCreatedCollectionProxy.new(creator)
    ids = proxy.xxxs_ids
    unless ids.include?(collection.id)
      proxy.add_to_cache(collection.id)
    end
  end

  def self.rules
    {
      :class => Collection ,
      :after_create => Proc.new {|collection|
        UserCreatedCollectionProxy.add_collection_cache(collection)
      },
      :after_destroy => Proc.new {|collection|
        UserCreatedCollectionProxy.remove_collection_cache(collection)
      }
    }
  end


  def self.funcs
    {
      :class  => User ,
      :created_collections => Proc.new {|user|
        UserCreatedCollectionProxy.new(user).get_models(Collection)
      }
    }
  end
  
end
