class Feed < UserAuthAbstract
  set_readonly false

  validates_presence_of :content
  validates_presence_of :creator
  validates_presence_of :event

  belongs_to :creator,:class_name=>"User",:foreign_key=>:creator_id

  SAY_OPERATE = 'say'

  named_scope :news_feeds_of_user,lambda {|user|
    {
      :conditions=>"feeds.creator_id = #{user.id}",
      :order=>'id desc'
    }
  }

  named_scope :normal,:conditions=>"hidden is not true",:order=>"feeds.id desc"
  named_scope :unhidden,:conditions=>"hidden is not true",:order=>"feeds.id desc"

  named_scope :hidden,:conditions=>"hidden is true",:order=>"feeds.id desc"

  after_create :creator_to_fav_feed_on_create
  def creator_to_fav_feed_on_create
    self.creator.add_fav_feed(self)
  end

  # 20110604 songliang 改为有tag的主题
  def self.recent_hot(paginate_options)
    Feed.find(:all,
      :select=>'DISTINCT feeds.*',
      :joins=>[
        'JOIN feed_tags FT ON FT.feed_id = feeds.id',
        'JOIN tags T ON FT.tag_id = T.id AND T.name != "没有关键词"',
      ],
      :order=>'feeds.id desc',
      :conditions=>['feeds.hidden = ?',false]).paginate(paginate_options)
  end

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

  def quotes
    Feed.find_all_by_quote_of(self.id)
  end

  def quotes_count
    quotes.length
  end

  def detail_content
    fd = self.feed_detail
    return "" if fd.blank?
    fd.content||""
  end

  # 临时方法，需要重构，各种判断纠结不清
  def update_all_attr(content, tags, detail_content, editor)
    return if self.locked? && !editor.is_admin_user?
    return if editor.blank?

    con1 = content != self.content
    con2 = detail_content != self.detail_content

    self.update_attributes(:content=>content) if con1
    self.create_or_update_detail(detail_content) if con2
    self.record_editer(editor,"") if con1 || con2
    self.reload
    
    self.change_tags(tags, editor)
  end

  def update_content(content,editor)
    return if self.locked? && !editor.is_admin_user?
    return if editor.blank?
    # 没有改动则不修改
    return self if content == self.content

    self.update_attributes(:content=>content)
    self.record_editer(editor,"修改标题")
  end
  
  # 话题详情
  def create_detail_content(detail_content)
    self.create_or_update_detail(detail_content)
  end

  # 话题详情
  def update_detail_content(detail_content,editor)
    return if self.locked? && !editor.is_admin_user?
    return if editor.blank?
    # 没有改动则不修改
    return self if detail_content == self.detail_content

    self.create_or_update_detail(detail_content)
    self.record_editer(editor,"修改正文")
    self.reload
    self
  end

  def show
    return if !self.hidden?
    self.update_attribute(:hidden,false)
  end

  def hide
    return if self.hidden?
    self.update_attribute(:hidden,true)
  end

  def to_show?
    return false if self.changes["hidden"].blank?
    !self.hidden?
  end

  def to_hide?
    return false if self.changes["hidden"].blank?
    self.hidden?
  end

  # 当话题是隐藏的
  # 并且 feed.spam_mark_effect? 不为真时
  # 返回 true
  def hidden_by_creator?
    self.hidden? && !self.spam_mark_effect?
  end

  # 当话题是隐藏的
  # 并且 feed.spam_mark_effect? 为真时
  # 返回 true
  def hidden_by_useless?
    self.hidden? && self.spam_mark_effect?
  end

  def send_invite_email(sender,recipient_email,title,postscript)
    Mailer.deliver_feed_invite(self,sender,recipient_email,title,postscript)
  end

  def lock
    self.update_attributes(:locked=>true) unless self.locked?
  end

  def unlock
    self.update_attributes(:locked=>false) if self.locked?
  end

  def lock_by(user)
    return false unless user.is_admin_user?
    self.lock
    return true
  end

  def unlock_by(user)
    return false unless user.is_admin_user?
    self.unlock
    return true
  end

  def related_feeds(count = 10)
    ActiveRecord::Base.connection.select_all(%`
        SELECT DISTINCT F1.id FROM feeds F
        JOIN feed_tags FT ON FT.feed_id = F.id
        JOIN feed_tags FT1 ON FT1.tag_id = FT.tag_id
        JOIN feeds F1 ON F1.id = FT1.feed_id
        WHERE F.id = #{self.id} AND F1.id <> #{self.id} AND F1.hidden = false
        ORDER BY F1.id desc
        LIMIT #{count}
      `).map{|item|Feed.find_by_id(item["id"])}.uniq.compact
  end

  def recommend_users(count=nil)
    except_users = self.be_invited_users | [self.creator] | self.memoed_users

    iusers = []
    self.tags.each do |tag|
      users = tag.users_of_memoed_feeds - except_users
      iusers|=users
      break if !count.blank? && iusers.count >=count
    end

    return iusers if count.blank?
    return iusers[0..count-1]
  end

  module UserMethods
    def self.included(base)
      base.has_many :created_feeds,:class_name=>"Feed",:foreign_key=>:creator_id
    end

    def send_say_feed(content,options={})
      channel_ids = options[:channel_ids] || []
      channels = channel_ids.map{|id|Channel.find_by_id(id)}.compact
      event = options[:event] || Feed::SAY_OPERATE
      
      feed = Feed.new(:creator=>self,:event=>event,:content=>content,:channels_db=>channels)
      return feed if !feed.valid?
      feed.save!
      feed.create_detail_content(options[:detail]) if !options[:detail].blank?

      feed.add_tags_without_record_editer(options[:tags],self)
      feed.add_default_tag_when_no_tag
      feed.record_editer(self)
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
        hd = HtmlDocument.new(:feed=>feed,:html=>html,:creator=>self)
        return false if !hd.valid? || !feed.valid?
        feed.save!
        hd.save!
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
        return feed
      end
    end

    def send_todolist_feed(title,options={})
    end

    def out_feeds_db
      Feed.news_feeds_of_user(self).unhidden
    end

    def all_feeds_count
      Feed.news_feeds_of_user(self).unhidden.count
    end

    def in_feeds_db
      _id_list = self.followings_and_self_by_db.map{|user|
        user.out_feeds_db.find(:all,:limit=>100,:order=>'id desc').map{|x| x.id}
      }.flatten
      # 排序，大的就是新的，排在前面
      _id_list = _id_list.compact.sort{|x,y| y<=>x}[0..99]
      _id_list.map{|id|Feed.find_by_id(id)}.compact.uniq
    end

    def hidden_feeds
      Feed.news_feeds_of_user(self).hidden
    end

  end

  include FeedMindmap::FeedMethods
  include Fav::FeedMethods
  include FeedChannel::FeedMethods
  include HtmlDocument::FeedMethods
  include FeedComment::FeedMethods
  include FeedLucene::FeedMethods
  include ShortUrl::FeedMethods
  include FeedRevision::FeedMethods
  include Viewpoint::FeedMethods
  include FeedInvite::FeedMethods
  include ViewpointDraft::FeedMethods
  include SpamMark::FeedMethods
  include FeedTag::FeedMethods
  include UserLog::FeedMethods
  include FeedTag::FeedMethods
  include FeedDetail::FeedMethods
  include FeedVote::FeedMethods
  include FeedViewing::FeedMethods
  include Atme::AtableMethods
end
