class User < UserBase
  include Mindmap::UserMethods
  
  # 两个工程都引入的
  include Fav::UserMethods
  include FeedChannel::UserMethods
  include Feed::UserMethods
  include Viewpoint::UserMethods
  include UserCooperationMethods
  include Channel::UserMethods
  include Contact::UserMethods
  include ChannelUser::UserMethods
  include ConnectUser::UserMethods
  include Tsina::UserMethods
  include MindmapFav::UserMethods
  include MindmapComment::UserMethods
  include FeedInvite::UserMethods
  include UserLog::UserMethods
  include TagFav::UserMethods
  include TagsMapOfUserCreatedFeedsProxy::UserMethods
  include TagsMapOfUserMemoedFeedsProxy::UserMethods
  include Atme::UserMethods
  include ReputationLog::UserMethods
  # 两个工程都引入的

  index :email
end