class UserIncomingFeedProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_incoming_feeds"
  end

  def xxxs_ids_db
    no_following_fans = @user.fans-@user.followings
    _ids_to_followings = no_following_fans.map do |user|
      UserToFollowingsOutboxFeedProxy.new(user).xxxs_ids
    end.flatten
    _ids_to_personnal = UserIncomingToPersonalInboxFeedProxy.new(@user).xxxs_ids
    _ids_to_channels = @user.belongs_to_no_followings_channels.map do |channel|
      UserChannelOutboxFeedProxy.new(channel).xxxs_ids
    end.flatten

    ids = _ids_to_followings + _ids_to_personnal + _ids_to_channels
    # 排序，大的就是新的，排在前面
    ids = ids.sort{|x,y| y<=>x}
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
      :incoming_feeds => Proc.new {|user|
        UserIncomingFeedProxy.new(user).get_models(Feed)
      }
    }
  end
end