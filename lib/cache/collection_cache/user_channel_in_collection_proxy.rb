class UserChannelInCollectionProxy < RedisBaseProxy

  def initialize(channel)
    @channel = channel
    @key = "user_channel_#{@channel.id}_in_collections"
  end

  def xxxs_ids_db
    ids = []
    creator = @channel.creator
    include_users = @channel.include_users
    channel_mutual_followings = (creator.mutual_followings & include_users)

    include_users.each{|user|
      ids+=UserOutCollectionProxy.new(user).xxxs_ids
    }

    channel_mutual_followings.each{|user|
      ids+=UserToFollowingsOutCollectionProxy.new(user).xxxs_ids
    }

    include_users.each do |user|
      channels = user.channels_of_user(creator)
      channels.each{|channel| ids+=UserChannelOutCollectionProxy.new(channel).xxxs_ids }
    end

    list_temp = []
    include_users.each do |user|
      list_temp += UserToPersonalOutCollectionProxy.new(user).xxxs_ids
    end
    ids+=(list_temp & UserToPersonalInCollectionProxy.new(creator).xxxs_ids)

    ids+=UserChannelOutCollectionProxy.new(@channel).xxxs_ids

    ids.uniq.sort{|x,y| y<=>x}
  end

  def xxxs_ids
    xxxs_ids_db
  end

  def self.rules
    []
  end

  def self.funcs
    {
      :class=>Channel,
      :in_collections=>Proc.new{|channel|
        UserChannelInCollectionProxy.new(channel).get_models(Collection)
      }
    }
  end

end
