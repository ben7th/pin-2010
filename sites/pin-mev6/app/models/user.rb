class User < UserBase
  include Mindmap::UserMethods
  
  # 两个工程都引入的
  include Fav::UserMethods
  include FeedChannel::UserMethods
  include Feed::UserMethods
  include TodoUser::UserMethods
  include UserCooperationMethods
  include Channel::UserMethods
  include Contact::UserMethods
  include ChannelUser::UserMethods
  include ConnectUser::UserMethods
  include Tsina::UserMethods
  include MindmapFav::UserMethods
  include MindmapComment::UserMethods
  # 两个工程都引入的

  index :email
end