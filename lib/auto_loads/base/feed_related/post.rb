class Post < UserAuthAbstract

  # 常量
  KIND_MAIN   = "main"
  KIND_NORMAL = "normal"

  FORMAT_HTML = "html"
  FORMAT_MARKDOWN = "markdown"

  # 字段声明

  # 该字段用于在校验时区分是单独创建还是关联创建
  # 例如，在创建feed时关联创建post
  # 设为 true 则可以跳过对 feed 的校验
  attr_accessor :create_by_feed

  # 数据关系
  belongs_to :feed
  belongs_to :user

  # 校验
  validates_presence_of :feed,:if=>Proc.new{|post| post.create_by_feed != true}
  validates_presence_of :user


  # 查询
  scope :limited, lambda {|count|
    {:limit=>count.to_i,:order=>"posts.updated_at desc"}
  }

  scope :normal,:conditions=>"kind = '#{KIND_NORMAL}'",
    :order=>"id asc"

  def main?
    self.kind == Post::KIND_MAIN
  end

  def detail_sections
    if FORMAT_MARKDOWN == self.text_format
      self.detail.split("\n\n").map{|section|section.gsub("\n","")}
    else
      text = self.detail.gsub(/<\/?(span|font|br|li|strong|blockquote|b)[^>]*>/,"")
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
      elsif post.memo != content
        post.add_memo(content)
      end
      post
    end

    def has_post?
      !self.posts.blank?
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

    def update_title_without_record_editor(title)
      post = self.main_post
      post.update_attribute(:title,title)
    end

    def update_detail_without_record_editor(detail)
      post = self.main_post
      post.update_attribute(:detail,detail)
    end
    
    def add_comment(user, comment_str)
      self.main_post.add_comment(user, comment_str)
    end
  end

  include PostComment::PostMethods
  #include UserLog::PostMethods
  include Atme::AtableMethods
  include Atme::PostMethods
  include PostPhoto::PostMethods
end
