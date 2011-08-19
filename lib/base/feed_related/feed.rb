class Feed < UserAuthAbstract
  SAY_OPERATE = 'say'

  belongs_to :creator,:class_name=>"User",:foreign_key=>:creator_id
  validates_presence_of :content
  validates_presence_of :creator
  validates_presence_of :event


  named_scope :news_feeds_of_user,lambda {|user|
    {
      :conditions=>"feeds.creator_id = #{user.id}",
      :order=>'id desc'
    }
  }

  named_scope :limited,lambda {|count|
    {:limit=>count}
  }

  named_scope :normal,:conditions=>"hidden is not true",:order=>"feeds.id desc"
  named_scope :unhidden,:conditions=>"hidden is not true",:order=>"feeds.id desc"
  named_scope :hidden,:conditions=>"hidden is true",:order=>"feeds.id desc"
  named_scope :no_reply,:conditions=>"posts.feed_id is null and feeds.hidden is not true",
    :joins=>"left join posts on posts.feed_id = feeds.id",
    :order=>"id desc"

  after_create :creator_to_fav_feed_on_create
  def creator_to_fav_feed_on_create
    self.creator.add_fav_feed(self)
  end

  def view_right?(user)
    return true if public?
    return false if user.blank?

    channels_db.each do |channel|
      if channel.is_include_users_or_creator?(user)
        return true
      end
    end
    return false
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

  def validate_on_create
    validate_content_length
    channel_ids = self.creator.channels_db_ids
    sent_c_ids = self.sent_channels.map{|c|c.id}
    cs = sent_c_ids-channel_ids

    unless cs.blank?
      errors.add(:base,"频道 #{cs*" "} 不是你的,你不能发送主题到别人的频道")
    end
  end

  def validate_content_length
    if self.content.split(//u).length > 255
      errors.add(:content,"内容长度不能超过 255 个字符")
    end
  end

  def send_by_main_user?(channel)
    channel.main_users.include?(self.creator)
  end

  def detail_content
    post = self.main_post
    return "" if post.blank?
    post.memo||""
  end

  def update_attrs_and_record_editor(editor,options)
    options.assert_valid_keys(:content,:detail_content,:tag_names_string,:message)
    return if self.locked? && !editor.is_admin_user?
    return if editor.blank?
    
    content = options[:content]
    detail_content = options[:detail_content]
    tag_names_string = options[:tag_names_string]
    tag_names_string = Tag::DEFAULT if tag_names_string == ""
    mesage = options[:message]|| ""

    con1 = (!content.blank? && content !=self.content)
    con2 = (!detail_content.blank? && detail_content !=self.detail_content)
    con3 = (!tag_names_string.nil?) && self.tag_has_change?(tag_names_string,editor)

    # 更新 feed 标题
    if con1
      self.update_attributes(:content=>content)
    end

    # 更新 feed 详细内容
    if con2
      self.create_or_update_main_post(detail_content)
    end

    # 更新 tags 详细内容
    if con3
      self.change_tags_without_record_editor(tag_names_string, editor)
    end

    if con1 || con2 || con3
      self.record_editer(editor,mesage)
    end

  end

  # 更新 feed content
  def update_content(content,editor)
    update_attrs_and_record_editor(editor,:content=>content,:message=>"修改标题")
  end
  
  # 更新 feed detail_content
  def update_detail_content(detail_content,editor)
    update_attrs_and_record_editor(editor,:detail_content=>detail_content,:message=>"修改正文")
  end

  def update_all_attr(content, tags, detail_content, editor)
    update_attrs_and_record_editor(editor,:content=>content,
      :detail_content=>detail_content,:tag_names_string=>tags
    )
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

  def comments
    self.main_post.comments
  end

  module UserMethods
    def self.included(base)
      base.has_many :created_feeds,:class_name=>"Feed",:foreign_key=>:creator_id
    end

    def send_feed(content,options={})
      event = options[:event] || Feed::SAY_OPERATE
      sendto = options[:sendto] || ""
      send_scopes = SendScope.build_list_form_string(sendto)

      feed = Feed.new(:creator=>self,:event=>event,:content=>content,:send_scopes=>send_scopes)
      return feed if !feed.valid?
      feed.save!

      feed.create_main_post(options[:detail]||"")

      tags = options[:tags]
      tags = Tag::DEFAULT if tags.blank?

      if !!options[:collection]
        options[:collection].add_feed(feed,self)
      end
      
      if !!options[:photo_names]
        (options[:photo_names]||"").split(",").each do |name|
          photo = PhotoAdpater.create_photo_by_file_name(name,self)
          feed.feed_photos.create(:photo=>photo)
        end
      end
      
      feed.add_tags_without_record_editer(tags,self)
      feed.record_editer(self)
      feed
    end

    def send_todolist_feed(title,options={})
    end

    def all_feeds_count
      Feed.news_feeds_of_user(self).unhidden.count
    end

    def sent_feeds_db
      Feed.news_feeds_of_user(self).normal
    end

    def hidden_feeds
      Feed.news_feeds_of_user(self).hidden
    end

    def out_feeds_db(limited_count = nil)
      conditions=%`
        feeds.creator_id = #{self.id}
          and feeds.hidden is not true
      `
      joins=%`
        inner join send_scopes on send_scopes.feed_id = feeds.id
          and send_scopes.param = '#{SendScope::ALL_PUBLIC}'
      `
      find_hash = {
        :conditions=>conditions,:joins=>joins,
        :order=>"feeds.id desc"
      }
      find_hash[:limit]=limited_count unless limited_count.nil?
      Feed.find(:all,find_hash)
    end

    def to_followings_out_feeds_db(limited_count = nil)
      conditions=%`
        feeds.creator_id = #{self.id}
          and feeds.hidden is not true
      `
      joins=%`
        inner join send_scopes on send_scopes.feed_id = feeds.id
          and send_scopes.param = '#{SendScope::ALL_FOLLOWINGS}'
      `
      find_hash = {
        :conditions=>conditions,:joins=>joins,
        :order=>"feeds.id desc"
      }
      find_hash[:limit]=limited_count unless limited_count.nil?
      Feed.find(:all,find_hash)
    end

    def to_personal_out_feeds_db(limited_count = nil)
      conditions=%`
        feeds.creator_id = #{self.id}
          and feeds.hidden is not true
      `
      joins=%`
        inner join send_scopes on send_scopes.feed_id = feeds.id
          and send_scopes.scope_type = 'User'
      `
      find_hash = {
        :conditions=>conditions,:joins=>joins,
        :order=>"feeds.id desc",
        :group=>"feeds.id"
      }
      find_hash[:limit]=limited_count unless limited_count.nil?
      Feed.find(:all,find_hash)
    end

  end

  include FeedMindmap::FeedMethods
  include Fav::FeedMethods
  include HtmlDocument::FeedMethods
  include FeedLucene::FeedMethods
  include ShortUrl::FeedMethods
  include FeedRevision::FeedMethods
  include Post::FeedMethods
  include FeedInvite::FeedMethods
  include PostDraft::FeedMethods
  include SpamMark::FeedMethods
  include FeedTag::FeedMethods
  include UserLog::FeedMethods
  include FeedTag::FeedMethods
  include FeedVote::FeedMethods
  include FeedViewing::FeedMethods
  include Atme::AtableMethods

  include SendScope::FeedMethods
  include FeedPhoto::FeedMethods
end
