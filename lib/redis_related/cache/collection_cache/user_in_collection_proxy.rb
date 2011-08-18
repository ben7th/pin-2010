class UserInCollectionProxy < RedisBaseProxy

  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_in_collections"
  end

  def xxxs_ids_db
    ids = []
    @user.followings.map{|user|
      ids+=UserOutCollectionProxy.new(user).xxxs_ids
    }
    @user.mutual_followings.map{|user|
      ids+=UserToFollowingsOutCollectionProxy.new(user).xxxs_ids
    }
    @user.belongs_to_followings_channels.map{|channel|
      ids+=UserChannelOutCollectionProxy.new(channel).xxxs_ids
    }
    ids+=UserToPersonalInCollectionProxy.new(@user).xxxs_ids
    ids+=UserCreatedCollectionProxy.new(@user).xxxs_ids
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
      :class=>User,
      :in_collections=>Proc.new{|user|
        UserInCollectionProxy.new(user).get_models(Collection)
      }
    }
  end
  
end
