class Feed < UserAuthAbstract

  # 常量
  FROM_WEB = "web"
  FROM_ANDROID = "android"
  FROMS = [FROM_WEB, FROM_ANDROID] # 来源

  # 字段声明
  attr_accessor :_send_weibo         # 如果为true，则保存时使用队列发送新浪微博，参考下文的回调方法
  attr_accessor :_related_draft      # 关联着相关的草稿实例，如果该项有值，则保存时将关联的草稿删除掉
  attr_accessor :_revision_message   # 该项如果非空，则保存时创建一个版本，并附带上该信息

  # 数据关系
  belongs_to :creator, :class_name=>"User", :foreign_key=>:creator_id
  has_one    :main_post, :class_name=>'Post', :conditions=>"kind = '#{Post::KIND_MAIN}'" # 不能写校验，也不能关联创建
  has_many   :posts, :dependent=>:destroy
  has_many   :memoed_users_db, :through=>:posts, :source=>:user,
             :order=>"posts.vote_score desc"

  has_many   :feed_revisions, :order=>"feed_revisions.id desc"
  has_many   :edited_users, :through=>:feed_revisions, :source=>:user,
             :order=>"feed_revisions.id desc"


  # 参数关联
  accepts_nested_attributes_for :posts

  # 校验
  validates_presence_of :posts
  validates_presence_of :creator
  validates_inclusion_of :from, :in=>FROMS

  # 查询
  named_scope :news_feeds_of_user,lambda {|user|
    {
      :conditions=>"feeds.creator_id = #{user.id}",
      :order=>'id desc'
    }
  }

  named_scope :limited,lambda {|count|
    {:limit=>count}
  }

  named_scope :normal,   :conditions=>"feeds.hidden IS NOT TRUE", :order=>"feeds.id DESC"
  named_scope :unhidden, :conditions=>"feeds.hidden IS NOT TRUE", :order=>"feeds.id DESC"
  named_scope :hidden,   :conditions=>"feeds.hidden IS TRUE",     :order=>"feeds.id DESC"
  named_scope :no_reply, :conditions=>"posts.feed_id IS NULL AND feeds.hidden IS NOT TRUE",
                           :joins=>"LEFT JOIN posts ON posts.feed_id = feeds.id",
                           :order=>"id DESC"

  def self.publics_db
    Feed.find_by_sql(%~
      SELECT DISTINCT F.* FROM feeds F
      JOIN feed_collections FC ON FC.feed_id = F.id
      JOIN collections C ON C.id = FC.collection_id
      WHERE C.send_status = '#{Collection::SendStatus::PUBLIC}'
      ORDER BY F.id DESC
    ~).uniq
  end

  def self.public_timeline(count=20)
    count = 200 if count > 200
    ids = AllPublicFeedsProxy.new.xxxs_ids[0...count]
    ids.map{|id|Feed.find_by_id(id)}.compact.uniq
  end

  # 回调
  after_save :_send_weibo_after_save
  def _send_weibo_after_save
    self.send_to_tsina if @_send_weibo == true
    @_send_weibo = nil
    return true
  end

  after_save :_delete_related_draft_after_save
  def _delete_related_draft_after_save
    @_related_draft.destroy if !!@_related_draft
    @_related_draft = nil
    return true
  end

  after_save :_record_editer_after_save
  def _record_editer_after_save
    self.record_editer(self.creator, @_revision_message) if !@_revision_message.blank?
    @_revision_message = nil
    return true
  end


  # 属性字段
  def title
    self.main_post.title
  rescue
    ''
  end

  def detail
    self.main_post.detail
  rescue
    ''
  end

  def photos
    self.main_post.photos
  rescue
    []
  end

  def comments
    self.main_post.comments
  rescue
    []
  end

  def location
    self.main_post.location
  rescue
    ''
  end

  def location_lat
    self.main_post.location.split(',')[0]
  rescue
    ''
  end
  
  def location_lng
    self.main_post.location.split(',')[1]
  rescue
    ''
  end

  # ----------------

  def text_format
    FeedFormat.new(self)
  end

  def http_url
    pin_url_for("pin-user-auth","/feeds/#{self.id}")
  end

  # 同步方法
  def send_to_tsina
    self.reload

    fdetail = self.detail
    ftitle  = self.title
    url     = self.http_url
    photos  = self.photos
    creator = self.creator

    length_limit = 126

    if ftitle.blank?
      status = truncate_u("#{fdetail}", length_limit)
    else
      status = truncate_u("『#{ftitle}』#{fdetail}", length_limit)
    end
    status = "#{status} #{url}"
    
    if photos.blank?
      creator.send_message_to_tsina_weibo_in_queue(status)
    else
      creator.send_photo_to_tsina_in_queue(photos[0].id,status)
    end
  end

  # since_id，可选，如果指定此参数，只返回id大于此id（时间上较早）的主题。
  # max_id，可选，如果指定此参数，只返回id小于或等于此id（时间上较晚）的主题。
  # count，可选，缺省值20，最大200。指定返回的条目数。
  # page，可选，缺省1
  # feature，可选，主题类型，'all', 'text', 'photo', 'text|photo'。默认all。后台应分别建立缓存。
  def self.mix_from_collections(collections, options={})
    count    = options[:count] || 20
    page     = options[:page]  || 1
    since_id = options[:since_id]
    since_id = since_id.to_i unless since_id.blank?
    max_id   = options[:max_id]
    max_id   = max_id.to_i unless max_id.blank?
    feature  = options[:feature] || "all"

    ids = collections.map do |collection|
      case feature
      when "all"        then collection.feed_ids
      when "text"       then collection.with_text_feed_ids
      when "photo"      then collection.with_photo_feed_ids
      when "text|photo" then collection.mixed_feed_ids
      end
    end.flatten.uniq.sort{|x,y| y<=>x}

    ids = ids.select{|id|id<=max_id} unless max_id.blank?
    ids = ids.select{|id|id>since_id} unless since_id.blank?

    first_index = (page-1)*count
    last_index  = first_index+count-1
    res_ids = ids[first_index..last_index]
    res_ids.map{|id|Feed.find_by_id(id)}.uniq.compact
  end

  ### modules
  
  module UserMethods
    def self.included(base)
      base.has_many :created_feeds,:class_name=>"Feed",:foreign_key=>:creator_id
    end

    # 转发
#    def repost(repost_feed_id,options={})
#      feed = Feed.new(:creator=>self)
#      rfeed = Feed.find(repost_feed_id)
#      if rfeed.repost_feed_id.blank?
#        feed.repost_feed_id = rfeed.id
#      else
#        feed.repost_feed_id = rfeed.repost_feed_id
#      end
#      _send_feed(feed,options)
#    end

    # 根据传入的参数发送一个主题
    def send_feed(options={})
      SendFeedAdapter.new(self, options).do_send
    end

    class SendFeedAdapter
      def initialize(creator, options={})
        @creator = creator

        @collection_ids = (options[:collection_ids]||'').split(',')
        raise "至少指定一个收集册" if @collection_ids.blank?

        @from         = options[:from] || FROM_WEB
        @draft_token = options[:draft_token]
        @photo_ids   = (options[:photo_ids]||'').split(',')

        @title       = options[:title]
        @detail      = options[:detail]
        @send_tsina  = options[:send_tsina] == 'true'
        @location = options[:location].blank? ? nil : options[:location]
      end

      def do_send
        photos      = @photo_ids.map{|id| Photo.find_by_id(id)}.uniq.compact
        collections = @collection_ids.map{|id| Collection.find_by_id(id)}.uniq.compact

        feed = Feed.new(
          :creator => @creator,
          :from    => @from,
          :collections => collections,
          :posts_attributes => [
            {
              :create_by_feed => true, # 跳过校验
              :location => @location,
              :user   => @creator,
              :title  => @title,
              :detail => @detail,
              :kind   => Post::KIND_MAIN,
              :text_format => Post::FORMAT_HTML,
              :photos => photos
            }
          ],

          :_send_weibo         => @send_tsina,
          :_related_draft      => PostDraft.find_by_draft_token(@draft_token),
          :_revision_message   => '创建主题'
        )
        
        feed.save!
        return feed
      end
    end

    #################
    public
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

    def home_timeline(options={})
      Feed.mix_from_collections(self.in_collections,options)
    end

    def user_timeline(options={})
      user_id = options[:user]
      if user_id.blank?
        collections = self.out_collections
      else
        user = User.find(user_id)
        collections = (self.created_collections && user.in_collections)
      end
      Feed.mix_from_collections(collections,options)
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

  module CollectionMethods
    def feeds_limit(options)
      Feed.mix_from_collections([self],options)
    end
  end

  include Fav::FeedMethods
  include FeedLucene::FeedMethods
  include ShortUrl::FeedMethods
  include FeedRevision::FeedMethods
  include Post::FeedMethods
  include FeedInvite::FeedMethods
  include SpamMark::FeedMethods
  include FeedTag::FeedMethods
  include UserLog::FeedMethods
  include FeedTag::FeedMethods
  include FeedVote::FeedMethods
  include FeedViewing::FeedMethods
  include Atme::AtableMethods
  
  include FeedCollection::FeedMethods
end