class UserPrivateCollectionProxy < RedisBaseProxy

  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_private_collections"
  end

  def xxxs_ids_db
    @user.private_collections_db.map{|x| x.id}
  end

  def self.remove_collection_cache(collection)
    creator = collection.creator
    return if creator.blank?
    UserPrivateCollectionProxy.new(creator).remove_from_cache(collection.id)
  end

  def self.add_collection_cache(collection)
    return unless collection.private?

    creator = collection.creator
    return if creator.blank?

    proxy = UserPrivateCollectionProxy.new(creator)
    ids = proxy.xxxs_ids
    unless ids.include?(collection.id)
      proxy.add_to_cache(collection.id)
    end
  end

  def self.rules
    {
      :class => Collection ,
      :after_create => Proc.new {|collection|
        UserPrivateCollectionProxy.add_collection_cache(collection)
      },
      :after_update => Proc.new{|collection|
        if collection.private?
          UserPrivateCollectionProxy.add_collection_cache(collection)
        else
          UserPrivateCollectionProxy.remove_collection_cache(collection)
        end
      },
      :after_destroy => Proc.new {|collection|
        UserPrivateCollectionProxy.remove_collection_cache(collection)
      }
    }
  end

  def self.funcs
    {
      :class=>User,
      :private_collections=>Proc.new{|user|
        UserPrivateCollectionProxy.new(user).get_models(Collection)
      }
    }
  end
  
end
