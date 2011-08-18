class UserChannelInboxFeedProxy < RedisBaseProxy
  def initialize(channel)
    @channel = channel
    @key = "user_channel_#{@channel.id}_inbox_feeds"
  end

  def xxxs_ids_db
    creator = @channel.creator
    users = @channel.include_users
    id_list = []
    # 1 在频道内的好友发送的公开主题
    users.each do |user|
      id_list += UserOutboxFeedProxy.new(user).xxxs_ids
    end
    #2 当互相关注时，频道中的这些好友把自己加入了他的某些频道，好友向这些频道发送的主题
    users.each do |user|
     channels = user.channels_of_user(creator)
     _ids = channels.map{|channel|UserChannelOutboxFeedProxy.new(channel).xxxs_ids}.flatten
     id_list += _ids
    end
    #3 频道的创建者向频道发送的主题
    id_list += UserChannelOutboxFeedProxy.new(@channel).xxxs_ids
    # 4(channel_include_users & mutual_followings).user_to_followings_outbox
    (creator.mutual_followings & users).each do |user|
      id_list += UserToFollowingsOutboxFeedProxy.new(user).xxxs_ids
    end

    # channel_include_users 发给个人的
    list_temp = []
    users.each do |user|
      list_temp += UserToPersonalOutboxFeedProxy.new(user).xxxs_ids
    end
    id_list += (list_temp & UserToPersonalInboxFeedProxy.new(creator).xxxs_ids)

    # 排序，大的就是新的，排在前面
    ids = id_list.sort{|x,y| y<=>x}.uniq
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
      :class  => Channel ,
      :in_feeds => Proc.new {|channel|
        UserChannelInboxFeedProxy.new(channel).get_models(Feed)
      }
    }
  end
end
