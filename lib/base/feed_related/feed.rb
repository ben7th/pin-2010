class Feed < UserAuthAbstract
  FROM_WEB = "web"
  FROM_ANDROID = "android"
  FROMS = [FROM_WEB,FROM_ANDROID]

  belongs_to :creator,:class_name=>"User",:foreign_key=>:creator_id
  validates_presence_of :creator
  validates_inclusion_of :from, :in =>FROMS

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

  def self.publics
    Feed.mix_from_collections(Collection.publics)
  end

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
    validate_repost_feed_id
  end

  def validate_content_length
    if self.detail.split(//u).length > 255
      errors.add(:base,"内容长度不能超过 255 个字符")
    end
  end

  def validate_repost_feed_id
    unless self.repost_feed_id.blank?
      fid = self.repost_feed_id
      feed = Feed.find_by_id(fid)
      if feed.blank? || !feed.repost_feed_id.blank?
        errors.add(:base,"不能嵌套转发")
      end
    end
  end

  def send_by_main_user?(channel)
    channel.main_users.include?(self.creator)
  end

  def update_attrs_and_record_editor(editor,options)
    options.assert_valid_keys(:title,:detail,:tag_names_string,:message)
    return if self.locked? && !editor.is_admin_user?
    return if editor.blank?
    
    title = options[:title]
    detail = options[:detail]
    tag_names_string = options[:tag_names_string]
    tag_names_string = Tag::DEFAULT if tag_names_string == ""
    mesage = options[:message]|| ""

    con1 = (!title.blank? && title !=self.title)
    con2 = (!detail.blank? && detail !=self.detail)
    con3 = (!tag_names_string.nil?) && self.tag_has_change?(tag_names_string,editor)

    # 更新 feed 标题
    if con1
      self.update_title_without_record_editor(title)
    end

    # 更新 feed 详细内容
    if con2
      self.update_detail_without_record_editor(detail)
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
  def update_title(title,editor)
    update_attrs_and_record_editor(editor,:title=>title,:message=>"修改标题")
  end
  
  # 更新 feed detail_content
  def update_detail(detail,editor)
    update_attrs_and_record_editor(editor,:detail=>detail,:message=>"修改正文")
  end

  def update_all_attr(title, tags, detail, editor)
    update_attrs_and_record_editor(editor,:title=>title,
      :detail=>detail,:tag_names_string=>tags
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

  def content_sections
    sections = []
    sections.push self.title
    post = self.main_post
    unless post.blank?
      sections+=post.detail_sections
    end
    sections
  end

  def weibo_sections
    result = []
    tmp = ""
    sections = self.content_sections
    sections.each do |section|
      tmp+=section
      if tmp.mb_chars.length >=130
        tmp=tmp.mb_chars[0...130].to_s
        result.push(tmp.clone)
        tmp = ""
      end
    end
    result.push tmp unless tmp.blank?
    result
  end

  def send_section_to_weibo(user)
    SendFeedSectionsQueueWorker.async_send_tsina_status(:feed_id=>self.id,:user_id=>user.id)
  end

  def title
    post = self.main_post
    return "" if post.blank?
    post.title||""
  end

  def detail
    post = self.main_post
    return "" if post.blank?
    post.detail||""
  end

  def photos
    self.main_post.photos
  end

  def self.mix_from_collections(collections)
      collections.map do |collection|
        collection.feed_ids
      end.flatten.uniq.sort{|x,y| y<=>x}.map{|fid|Feed.find_by_id(fid)}.compact
  end

  def self.mix_ids_from_collections(collections)
      collections.map do |collection|
        collection.feed_ids
      end.flatten.uniq.sort{|x,y| y<=>x}
  end

  module UserMethods
    def self.included(base)
      base.has_many :created_feeds,:class_name=>"Feed",:foreign_key=>:creator_id
    end

    def repost(repost_feed_id,title,detail,options={})
      feed = Feed.new(:creator=>self)
      rfeed = Feed.find(repost_feed_id)
      if rfeed.repost_feed_id.blank?
        feed.repost_feed_id = rfeed.id
      else
        feed.repost_feed_id = rfeed.repost_feed_id
      end
      _send_feed(feed,title,detail,options)
    end

    def send_feed(title,detail,options={})
      feed = Feed.new(:creator=>self)
      _send_feed(feed,title,detail,options)
    end

    def _send_feed(feed,title,detail,options={})
      from = (options[:from]||FROM_WEB)
      feed.from = from
      return feed if !feed.valid?
      feed.save!

      feed.create_main_post(title,detail)

      tags = options[:tags]
      tags = Tag::DEFAULT if tags.blank?

      cids = (options[:collection_ids]||"").split(",")
      raise "最少指定一个收集册" if cids.blank?
      cids.each do |collection_id|
        collection = Collection.find(collection_id)
        fc = FeedCollection.find_by_feed_id_and_collection_id(feed.id,collection.id)
        FeedCollection.create(:feed=>feed,:collection=>collection) if fc.blank?
      end

      if !!options[:photo_names]
        (options[:photo_names]||"").split(",").each do |name|
          photo = PhotoAdpater.create_photo_by_file_name(name,self)
          feed.main_post.post_photos.create(:photo=>photo)
        end
      end

      feed.add_tags_without_record_editer(tags,self)
      feed.record_editer(self)
      feed
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

    #############
    def out_feeds
      Feed.mix_from_collections(self.out_collections)
    end
    
    def private_feeds
      Feed.mix_from_collections(self.private_collections)
    end

    def in_feeds
      Feed.mix_from_collections(self.in_collections)
    end

    def to_followings_out_feeds
      Feed.mix_from_collections(self.to_followings_out_collections)
    end

    def incoming_feeds
      Feed.mix_from_collections(self.incoming_collections)
    end

    def to_personal_out_feeds
      Feed.mix_from_collections(self.to_personal_out_collections)
    end

    def to_personal_in_feeds
      Feed.mix_from_collections(self.to_personal_in_collections)
    end

    def incoming_to_personal_in_feeds
      Feed.mix_from_collections(self.incoming_to_personal_in_collections)
    end

    def newest_feed(user)
      if user.blank?
        self.out_feeds.first
      else
        (self.sent_feeds && user.in_feeds).first
      end
    end
  end

  module ChannelMethods
    def out_feeds
      Feed.mix_from_collections(self.out_collections)
    end

    def in_feeds
      Feed.mix_from_collections(self.in_collections)
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

  include FeedCollection::FeedMethods
end
