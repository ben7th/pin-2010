class Post < UserAuthAbstract

  belongs_to :feed
  belongs_to :user
  validates_presence_of :feed,:on=>:create
  validates_presence_of :user,:on=>:create

  KIND_MAIN = "main"
  KIND_NORMAL = "normal"

  FORMAT_HTML = "html"
  FORMAT_MARKDOWN = "markdown"

  named_scope :limited, lambda {|count|
    {:limit=>count.to_i,:order=>"posts.updated_at desc"}
  }

  named_scope :normal,:conditions=>"kind = '#{KIND_NORMAL}'",
    :order=>"id asc"

  def add_memo(memo)
    self.update_attributes(:memo=>memo)
  end

  def has_memo?
    !self.memo.blank?
  end

  after_create :remove_feed_invite
  after_update :remove_feed_invite
  def remove_feed_invite
    feed = self.feed
    user = self.user
    return if feed.blank? || user.blank?
    fi = FeedInvite.find_by_feed_id_and_user_id(feed.id,user.id)
    fi.destroy unless fi.blank?
    return true
  end

  def memo_sections
    if FORMAT_MARKDOWN == self.text_format
      self.memo.split("\n\n").map{|section|section.gsub("\n","")}
    else
      text = self.memo.gsub(/<\/?(span|font|br|li|strong|blockquote|b)[^>]*>/,"")
      text.gsub(/<(p|ol)[^>]*>[^<]+<\/\1>/).to_a.map{|str|str.gsub(/<\/?[^>]*>/,"")}
    end
  end

  module UserMethods
    def self.included(base)
      base.has_many :posts,:order=>"posts.updated_at desc"
      base.has_many :memoed_feeds_db,:through=>:posts,:source=>:feed
    end

    def all_posts_count
      self.posts.count
    end

    def posts_limit(count)
      self.posts.limited(count)
    end

    def top_posts_db
      self.posts.select do |post|
        feed=post.feed
        if feed.blank?
          false
        else
          feed.hot_post == post
        end
      end
    end

  end

  module FeedMethods
    def self.included(base)
      base.has_many :posts
      base.has_many :memoed_posts,:class_name=>"Post",:conditions=>"posts.memo is not null",:order=>'vote_score desc'
      base.has_many :memoed_users_db,:through=>:posts,:source=>:user,
        :order=>"posts.vote_score desc"
    end

    def post_of(user)
      self.posts.find_by_user_id(user.id)
    end

    def post_by?(user)
      !post_of(user).blank?
    end
    
    # 创建对 feed 的观点
    def create_or_update_post(user,content)
      post = self.post_of(user)
      if post.blank?
        post = Post.create(:feed=>self,:user=>user,:memo=>content)
        post.record_editer(user)
      elsif post.memo != content
        post.add_memo(content)
        post.record_editer(user)
      end
      post
    end

    def has_post?
      !self.posts.blank?
    end

    def hot_post
      post = self.posts.first
      return if post.vote_score <= 0
      return post
    end

    def memoed_users
      memoed_users_db
    end

    def joined_users_and_creator
      users = memoed_users+[self.creator]
      users.uniq
    end

    def friends_who_joined_it_of(user)
      (user.following_user_ids & self.memoed_users_db_ids).map do |uid|
        User.find_by_id(uid)
      end.compact
    end

    def main_post
      self.posts.find_by_kind(Post::KIND_MAIN)
    end

    def create_main_post(content)
      self.posts.create(:user=>self.creator,
        :memo=>content,:kind=>Post::KIND_MAIN,:text_format=>Post::FORMAT_HTML)
    end

    def create_or_update_main_post(content)
      post = self.main_post
      if post.blank?
        create_main_post(content)
      else
        post.update_attribute(:memo,content)
      end
    end

  end

  include PostComment::PostMethods
  include PostVote::PostMethods
  include PostDraft::PostMethods
  #include UserLog::PostMethods
  include PostSpamMark::PostMethods
  include Atme::AtableMethods
  include Atme::PostMethods
  include PostRevision::PostMethods
end
