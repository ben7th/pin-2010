class UserChannelOutCollectionProxy < RedisBaseProxy

  def initialize(channel)
    @channel = channel
    @key = "user_channel_#{@channel.id}_out_collections"
  end

  def xxxs_ids_db
    @channel.out_collections_db.map{|x| x.id}
  end

  def self.remove_collection_cache(collection_scope)
    return if collection_scope.scope_type != "Channel"

    collection = collection_scope.collection
    channel = collection_scope.scope
    return if channel.blank?
    UserChannelOutCollectionProxy.new(channel).remove_from_cache(collection.id)
  end

  def self.add_collection_cache(collection_scope)
    return if collection_scope.scope_type != "Channel"

    collection = collection_scope.collection
    channel = collection_scope.scope
    return if channel.blank?

    proxy = UserChannelOutCollectionProxy.new(channel)
    ids = proxy.xxxs_ids
    unless ids.include?(collection.id)
      proxy.add_to_cache(collection.id)
    end
  end

  def self.rules
    {
      :class => CollectionScope ,
      :after_create => Proc.new {|collection_scope|
        UserChannelOutCollectionProxy.add_collection_cache(collection_scope)
      },
      :after_destroy => Proc.new {|collection_scope|
        UserChannelOutCollectionProxy.remove_collection_cache(collection_scope)
      }
    }
  end


  def self.funcs
    {
      :class=>Channel,
      :out_collections=>Proc.new{|channel|
        UserChannelOutCollectionProxy.new(channel).get_models(Collection)
      }
    }
  end

end
