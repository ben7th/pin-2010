class Feed < UserAuthAbstract
  set_readonly false

  validates_presence_of :content
  validates_presence_of :creator
  validates_presence_of :event

  belongs_to :creator,:class_name=>"User",:foreign_key=>:creator_id

  SAY_OPERATE = 'say'

  named_scope :news_feeds_of_user,lambda {|user|
    {:conditions=>"feeds.creator_id = #{user.id}"}
  }

  def replied_feed
    Feed.find_by_id(reply_to)
  end

  def quoted_feed
    Feed.find_by_id(quote_of)
  end

  def validate_on_create
    validate_content_length
    channels = self.creator.belongs_to_channels_db + self.creator.channels
    self.channels_db.each do |channel|
      next if channel.kind == Channel::KIND_INTERVIEW
      if !channels.include?(channel)
        errors.add(:base,"您没有向 #{channel.name} 频道发送内容的权限")
        break
      end
    end
  end

  def validate_content_length
    if self.content.split(//u).length > 255
      errors.add(:content,"内容长度不能超过 255 个字符")
    end
  end

  def self.reply_to_feed(user,content,create_new_feed,host_feed,channel_ids=[])
    if create_new_feed == "true"
      self._create_comment_and_new_feed(user,content,host_feed,channel_ids)
    else
      self._create_comment(user,content,host_feed)
    end
  end

  def self._create_comment(user,content,host_feed)
    fc = FeedComment.new(:feed_id=>host_feed.id,:content=>content,:user_id=>user.id)
    return false if !fc.valid?
    fc.save!
    UserBeingRepliedCommentsProxy.update_feed_comment(fc)
    fc
  end

  def self._create_comment_and_new_feed(user,content,host_feed,channel_ids)
    channel_ids = [] if channel_ids.blank?
    channels = channel_ids.map{|id|Channel.find_by_id(id)}.compact
    host_feed_id = host_feed.id
    Feed.transaction do
      fc = FeedComment.new(:feed_id=>host_feed_id,:content=>content,:user_id=>user.id)
      feed = Feed.new(:creator=>user,:event=>SAY_OPERATE,:content=>content,:channels_db=>channels,:reply_to=>host_feed_id)
      return false if !fc.valid?
      return false if !feed.valid?
      fc.save!
      feed.save!
      UserBeingRepliedCommentsProxy.update_feed_comment(fc)
      user.news_feed_proxy.update_feed(feed)
      return fc
    end
  end

  #
  def self.to_quote_feed(user,content,quote_feed,options={})
    channel_ids = options[:channel_ids] || []
    channels = channel_ids.map{|id|Channel.find_by_id(id)}.compact
    Feed.transaction do
      feed = Feed.new(:creator=>user,:event=>Feed::SAY_OPERATE,:content=>content,:channels_db=>channels,:quote_of=>quote_feed.id)
      return false if !feed.valid?
      feed.save!
      if feed.id
        user.news_feed_proxy.update_feed(feed)
      end
      return feed
    end
  end

  def reply_feeds
    Feed.find_all_by_reply_to(self.id)
  end

  def reply_feeds_of(users)
    reply_feeds.select do |feed|
      users.include?(feed.creator)
    end
  end
  
  def reply_comments_of(users)
    FeedComment.find_all_by_feed_id(self.id).select do |feed_comment|
      users.include?(feed_comment.user)
    end
  end

  def send_by_main_user?(channel)
    channel.main_users.include?(self.creator)
  end

  module UserMethods
    def send_say_feed(content,options={})
      channel_ids = options[:channel_ids] || []
      channels = channel_ids.map{|id|Channel.find_by_id(id)}.compact
      feed = Feed.new(:creator=>self,:event=>Feed::SAY_OPERATE,:content=>content,:channels_db=>channels)
      return false if !feed.valid?
      feed.save!
      self.news_feed_proxy.update_feed(feed)
      feed
    end

    # option :channel_ids
    def send_html_document_feed(title,html,options={})
      channel_ids = options[:channel_ids] || []
      channels = channel_ids.map{|id|Channel.find_by_id(id)}.compact
      Feed.transaction do
        feed = Feed.new(
        :creator=>self,:event=>Feed::SAY_OPERATE,
        :content=>title,:channels_db=>channels)
        hd = HtmlDocument.new(:feed=>feed,:html=>html)
        return false if !hd.valid? || !feed.valid?
        feed.save!
        hd.save!
        self.news_feed_proxy.update_feed(feed)
        return feed
      end
    end

    # option :channel_ids
    def send_mindmap_feed(title,options={})
      channel_ids = options[:channel_ids] || []
      channels = channel_ids.map{|id|Channel.find_by_id(id)}.compact
      Feed.transaction do
        feed = Feed.new(
        :creator=>self,:event=>Feed::SAY_OPERATE,
        :content=>title,:channels_db=>channels)
        return false if !feed.valid?
        feed.save!
        mindmap = Mindmap.create_by_title!(self,title)
        FeedMindmap.create!(:mindmap=>mindmap,:feed=>feed)
        self.news_feed_proxy.update_feed(feed)
        return feed
      end
    end

    def in_feeds
      self.news_feed_proxy.feeds
    end

    def refresh_newest_feed_id
      self.news_feed_proxy.refresh_newest_feed_id
    end
  end

  include FeedMindmap::FeedMethods
  include Fav::FeedMethods
  include FavProxy::FeedMethods
  include FeedMindmapProxy::FeedMethods
  include FeedChannel::FeedMethods
  include HtmlDocument::FeedMethods
  include FeedComment::FeedMethods
  include FeedLucene::FeedMethods
end
