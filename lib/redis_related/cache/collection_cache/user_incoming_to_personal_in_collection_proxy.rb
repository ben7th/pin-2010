class UserIncomingToPersonalInCollectionProxy < RedisBaseProxy

  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_incoming_to_personal_in_collections"
  end

  def xxxs_ids_db
    @user.incoming_to_personal_in_collections_db.map{|x| x.id}
  end

  def self.remove_collection_cache(collection_scope)
    return if collection_scope.scope_type != "User"

    collection = collection_scope.collection
    user = collection_scope.scope
    return if user.blank?
    UserIncomingToPersonalInCollectionProxy.new(user).remove_from_cache(collection.id)
  end
  
  def self.add_collection_cache(collection_scope)
    return if collection_scope.scope_type != "User"

    collection = collection_scope.collection
    user = collection_scope.scope
    return if user.blank?
    return if user.followings.include?(collection.creator)

    proxy = UserIncomingToPersonalInCollectionProxy.new(user)
    ids = proxy.xxxs_ids
    unless ids.include?(collection.id)
      proxy.add_to_cache(collection.id)
    end
  end

  def self.syn_cache_when_create_channel_user(channel_user)
    user = channel_user.user
    channel = channel_user.channel
    channels = channel.creator.channels_of_user(user)
    return if (channels-[channel]).count != 0

    collection_ids = follow_user_to_user_collection_ids(user,channel.creator)

    proxy = UserIncomingToPersonalInCollectionProxy.new(channel.creator)
    ids = proxy.xxxs_ids
    new_ids = ids - collection_ids
    # 排序，大的就是新的，排在前面
    new_ids = new_ids.sort{|x,y| y<=>x}.uniq
    new_ids = new_ids[0..99] if new_ids.length > 100
    proxy.send(:xxxs_ids_rediscache_save,new_ids)
  end

  def self.syn_cache_when_destroy_channel_user(channel_user)
    user = channel_user.user
    channel = channel_user.channel
    channels = channel.creator.channels_of_user(user)
    return if (channels-[channel]).count != 0

    collection_ids = follow_user_to_user_collection_ids(user,channel.creator)
    proxy = UserIncomingToPersonalInCollectionProxy.new(channel.creator)
    ids = proxy.xxxs_ids
    new_ids = ids + collection_ids
    # 排序，大的就是新的，排在前面
    new_ids = new_ids.sort{|x,y| y<=>x}.uniq
    new_ids = new_ids[0..99] if new_ids.length > 100
    proxy.send(:xxxs_ids_rediscache_save,new_ids)
  end

  def self.rules
    [
      {
        :class => CollectionScope ,
        :after_create => Proc.new {|collection_scope|
          UserIncomingToPersonalInCollectionProxy.add_collection_cache(collection_scope)
        },
        :after_destroy => Proc.new {|collection_scope|
          UserIncomingToPersonalInCollectionProxy.remove_collection_cache(collection_scope)
        }
      },
      {
        :class => ChannelUser,
        :after_create => Proc.new {|channel_user|
          UserIncomingToPersonalInCollectionProxy.syn_cache_when_create_channel_user(channel_user)
        },
        :after_destroy => Proc.new{|channel_user|
          UserIncomingToPersonalInCollectionProxy.syn_cache_when_destroy_channel_user(channel_user)
        }
      }
    ]
  end

  def self.funcs
    {
      :class=>User,
      :incoming_to_personal_in_collections=>Proc.new{|user|
        UserIncomingToPersonalInCollectionProxy.new(user).get_models(Collection)
      }
    }
  end

  private
  def self.follow_user_to_user_collection_ids(follow_user,user)
    Collection.find(:all,
      :conditions=>"collections.creator_id = #{follow_user.id} and collection_scopes.scope_type = 'User' and collection_scopes.scope_id = #{user.id}",
      :joins=>"inner join collection_scopes on collections.id = collection_scopes.collection_id",
      :order=>"collections.id desc"
    ).map{|f|f.id}
  end
end
