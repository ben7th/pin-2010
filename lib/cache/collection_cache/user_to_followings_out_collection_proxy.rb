class UserToFollowingsOutCollectionProxy < RedisBaseProxy

  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_to_followings_out_collections"
  end

  def xxxs_ids_db
    @user.to_followings_out_collections_db.map{|x| x.id}
  end

  def self.remove_collection_cache(collection_scope)
    return if collection_scope.param != CollectionScope::ALL_FOLLOWINGS

    collection = collection_scope.collection
    creator = collection.creator
    return if creator.blank?
    UserToFollowingsOutCollectionProxy.new(creator).remove_from_cache(collection.id)
  end

  def self.add_collection_cache(collection_scope)
    return if collection_scope.param != CollectionScope::ALL_FOLLOWINGS

    collection = collection_scope.collection
    creator = collection.creator
    return if creator.blank?

    proxy = UserToFollowingsOutCollectionProxy.new(creator)
    ids = proxy.xxxs_ids
    unless ids.include?(collection.id)
      proxy.add_to_cache(collection.id)
    end
  end

  def self.rules
    {
      :class => CollectionScope ,
      :after_create => Proc.new {|collection_scope|
        UserToFollowingsOutCollectionProxy.add_collection_cache(collection_scope)
      },
      :after_destroy => Proc.new {|collection_scope|
        UserToFollowingsOutCollectionProxy.remove_collection_cache(collection_scope)
      }
    }
  end

  def self.funcs
    {
      :class=>User,
      :to_followings_out_collections=>Proc.new{|user|
        UserToFollowingsOutCollectionProxy.new(user).get_models(Collection)
      }
    }
  end
  
end
