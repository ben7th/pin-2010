class User < UserBase
  include Mindmap::UserMethods
  include MindmapComment::UserMethods
  include MindmapFav::UserMethods
  include MindmapFavProxy::UserMethods
  
  # 两个工程都引入的
  include Fav::UserMethods
  include FavProxy::UserMethods
  include ChannelCacheProxy::UserMethods
  include FeedChannel::UserMethods
  include Feed::UserMethods
  include FeedCommentProxy::UserMethods
  include UserBeingQuotedFeedsProxy::UserMethods
  include TodoUser::UserMethods
  include TodoProxy::UserMethods
  include UserCooperationMethods
  include CooperationMindmapProxy::UserMethods
  include Channel::UserMethods
  include NoChannelNewsFeedProxy::UserMethods
  include Contact::UserMethods
  # 两个工程都引入的

  index :email
end