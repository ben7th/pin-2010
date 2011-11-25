class UserToPersonalOutCollectionProxy < RedisBaseProxy

  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_to_personal_out_collections"
  end

  def xxxs_ids_db
    @user.to_personal_out_collections_db.map{|x| x.id}
  end

  def self.remove_collection_cache(collection_scope)
    return if collection_scope.scope_type != "User"

    collection = collection_scope.collection
    creator = collection.creator
    return if creator.blank?
    UserToPersonalOutCollectionProxy.new(creator).remove_from_cache(collection.id)
  end
  
  def self.add_collection_cache(collection_scope)
    return if collection_scope.scope_type != "User"

    collection = collection_scope.collection
    creator = collection.creator
    return if creator.blank?

    proxy = UserToPersonalOutCollectionProxy.new(creator)
    ids = proxy.xxxs_ids
    unless ids.include?(collection.id)
      proxy.add_to_cache(collection.id)
    end
  end

  def self.rules
    {
      :class => CollectionScope ,
      :after_create => Proc.new {|collection_scope|
        UserToPersonalOutCollectionProxy.add_collection_cache(collection_scope)
      },
      :after_destroy => Proc.new {|collection_scope|
        UserToPersonalOutCollectionProxy.remove_collection_cache(collection_scope)
      }
    }
  end

  def self.funcs
    {
      :class=>User,
      :to_personal_out_collections=>Proc.new{|user|
        UserToPersonalOutCollectionProxy.new(user).get_models(Collection)
      }
    }
  end
  
end
