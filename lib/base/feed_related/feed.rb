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
    ft = self.first_todo
    return if ft.blank?
    fti = ft.first_todo_item
    return if fti.blank?
    fti.content
  end

  def update_content(content,editer)
    return if editer.blank?
    self.update_attribute(:content,content)
    self.record_editer(editer)
  end
  
  # 话题详情
  def update_detail_content(content,editer)
    return if editer.blank?
    todo = self.get_or_create_first_todo
    todo.create_or_update_todo_item(content)
    self.record_editer(editer)
  end


  # 创建对 feed 的观点
  def create_or_update_viewpoint(user,content)
    todo = self.get_or_create_first_todo
    todo_user = user.get_or_create_todo_user_by_todo(todo)
    todo_user.add_memo(content)
    todo_user
  end

  def memoed_viewpoints
    viewpoints.select{|vp|vp.has_memo?}
  end

  def viewpoints
    ft = self.first_todo
    return [] if ft.blank?
    ft.todo_users
  end

  def viewpoint_of(user)
    todo = self.first_todo
    return if todo.blank?
    todo_user = user.get_todo_user_by_todo(todo)
    return if todo_user.blank?
    todo_user
  end

  def viewpoint_by?(user)
    todo = self.first_todo
    return false if todo.blank?
    todo_user = user.get_todo_user_by_todo(todo)
    return false if todo_user.blank?
    todo_user.has_memo?
  end

  def has_viewpoint?
    viewpoints = self.viewpoints
    return false if viewpoints.blank?
    viewpoints.each do |todo_user|
      if todo_user.has_memo?
        return true
      end
    end
    return false
  end

  def hot_viewpoint
    self.viewpoints.first
  end

  def be_asked_users
    be_asked_users_db
  end

  def memoed_users
    memoed_users_db
  end

  # 被邀请的用户
  def be_asked_users_db
    todo = self.first_todo
    return [] if todo.blank?
    todo.be_asked_users_db
  end

  # 参与的用户
  def memoed_users_db
    todo = self.first_todo
    return [] if todo.blank?
    todo.memoed_users_db
  end

  # 邀请用户参与话题
  def add_be_asked_users(users)
    todo = self.get_or_create_first_todo
    users.each{|user|user.get_or_create_todo_user_by_todo(todo)}
  end

  module UserMethods
    def send_say_feed(content,options={})
      channel_ids = options[:channel_ids] || []
      channels = channel_ids.map{|id|Channel.find_by_id(id)}.compact
      feed = Feed.new(:creator=>self,:event=>Feed::SAY_OPERATE,:content=>content,:channels_db=>channels)
      return false if !feed.valid?
      feed.save!
      feed.update_detail_content(options[:detail]) if !options[:detail].blank?
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
      channel_ids = options[:channel_ids] || []
      channels = channel_ids.map{|id|Channel.find_by_id(id)}.compact
      Feed.transaction do
        feed = Feed.new(
          :creator=>self,:event=>Feed::SAY_OPERATE,
          :content=>title,:channels_db=>channels)
        todo = Todo.new(:creator=>self,:feed=>feed)
        return false if !todo.valid? || !feed.valid?
        feed.save!
        todo.save!
        return feed
      end
    end

    def out_feeds_db
      Feed.news_feeds_of_user(self)
    end

    def in_feeds_db
      _id_list = self.followings_and_self_by_db.map{|user|
        user.out_feeds_db.find(:all,:limit=>100,:order=>'id desc').map{|x| x.id}
      }.flatten
      # 排序，大的就是新的，排在前面
      _id_list = _id_list.compact.sort{|x,y| y<=>x}[0..99]
      _id_list.map{|id|Feed.find_by_id(id)}.compact.uniq
    end

    # 我参与的话题
    def memoed_feeds_db
      self.memoed_todos_db.map do |todo|
        todo.feed
      end.compact
    end

    # 被邀请参加的话题
    def be_asked_feeds_db
      self.be_asked_todos_db.map do |todo|
        todo.feed
      end.compact
    end
  end

  include FeedMindmap::FeedMethods
  include Fav::FeedMethods
  include FeedChannel::FeedMethods
  include HtmlDocument::FeedMethods
  include FeedComment::FeedMethods
  include FeedLucene::FeedMethods
  include Todo::FeedMethods
  include ShortUrl::FeedMethods
  include FeedChange::FeedMethods
end
