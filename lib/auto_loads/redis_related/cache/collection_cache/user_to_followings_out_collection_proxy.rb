class UserToFollowingsOutCollectionProxy < RedisBaseProxy

  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_to_followings_out_collections"
  end

  def xxxs_ids_db
    @user.to_followings_out_collections_db.map{|x| x.id}
  end

  def self.remove_collection_cache(collection)
    creator = collection.creator
    return if creator.blank?
    UserToFollowingsOutCollectionProxy.new(creator).remove_from_cache(collection.id)
  end

  def self.add_collection_cache(collection)
    return unless collection.sent_all_followings?

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
      :class => Collection ,
      :after_create => Proc.new {|collection|
        UserToFollowingsOutCollectionProxy.add_collection_cache(collection)
      },
      :after_update => Proc.new{|collection|
        if collection.sent_all_followings?
          UserToFollowingsOutCollectionProxy.add_collection_cache(collection)
        else
          UserToFollowingsOutCollectionProxy.remove_collection_cache(collection)
        end
      },
      :after_destroy => Proc.new {|collection|
        UserToFollowingsOutCollectionProxy.remove_collection_cache(collection)
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
