class Feed < FeedBase
  set_readonly false

  validates_presence_of :content
  validates_presence_of :email
  validates_presence_of :event

  belongs_to :creator,:class_name=>"User",:foreign_key=>"email",:primary_key=>"email"

  SAY_OPERATE = 'say'

  def validate_on_create
    channels = self.creator.belongs_to_channels_db + self.creator.channels
    self.channels_db.each do |channel|
      if !channels.include?(channel)
        errors.add(:base,"您没有向 #{channel.name} 频道发送内容的权限")
        break
      end
    end
  end

  def self.do_say(user,content,channel_ids=[])
    channels = [] if channel_ids.blank?
    channels = channel_ids.map{|id|Channel.find_by_id(id)}.compact
    feed = Feed.create(:email=>user.email,:event=>SAY_OPERATE,:content=>content,:channels_db=>channels)
    if feed.id
      user.news_feed_proxy.update_feed(feed)
    end
    feed
  end

  include FeedMindmap::FeedMethods
  include Fav::FeedMethods
  include FavProxy::FeedMethods
  include FeedMindmapProxy::FeedMethods
  include FeedChannel::FeedMethods
end
