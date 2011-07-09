class UserInboxFeedProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_inbox_feeds"
  end

  def xxxs_ids_db
    id_list_from_followings_and_self_newer_than(nil)
  end

  def id_list_from_followings_and_self_newer_than(newest_id)
    _id_list_public = @user.followings_and_self.map{|user|
      UserOutboxFeedProxy.new(user).xxxs_ids
    }.flatten
    _id_list_channels = @user.belongs_to_followings_channels.map{|channel|
      UserChannelOutboxFeedProxy.new(channel).xxxs_ids
    }.flatten

    _id_list = _id_list_channels + _id_list_public
    # 排序，大的就是新的，排在前面
    ids = _id_list.sort{|x,y| y<=>x}

    if !newest_id.nil?
      ids = ids.compact.select{|x| x > newest_id}
    end
    
    ids[0..199]
  end

  def xxxs_ids
    xxxs_ids_db
  end

  def self.rules
    []
  end

  def self.funcs
    {
      :class  => User ,
      :in_feeds => Proc.new {|user|
        UserInboxFeedProxy.new(user).get_models(Feed)
      },
      :in_feeds_more => Proc.new {|user,count,vector|
        UserInboxFeedProxy.new(user).vector_more(count,Feed,vector)
      },
      :in_feeds_count => Proc.new {|user|
        UserInboxFeedProxy.new(user).xxxs_ids.length
      }
    }
  end
end