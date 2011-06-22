class Viewpoint < UserAuthAbstract

  belongs_to :feed
  belongs_to :user
  validates_presence_of :feed,:on=>:create
  validates_presence_of :user,:on=>:create
  validates_presence_of :memo
  validates_uniqueness_of :feed_id, :scope => :user_id

  named_scope :limited, lambda {|count|
    {:limit=>count.to_i,:order=>"viewpoints.updated_at desc"}
  }

  def add_memo(memo)
    self.update_attributes(:memo=>memo)
  end

  def has_memo?
    !self.memo.blank?
  end

  def create_viewpoint_feed(user,content)
    Feed.create(:event=>Feed::SAY_OPERATE,
      :content=>content,:creator=>user,:from_viewpoint=>self.id)
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

  module UserMethods
    def self.included(base)
      base.has_many :viewpoints,:order=>"viewpoints.updated_at desc"
      base.has_many :memoed_feeds_db,:through=>:viewpoints,:source=>:feed
    end

    def all_viewpoints_count
      self.viewpoints.count
    end

    def viewpoints_limit(count)
      self.viewpoints.limited(count)
    end

    def top_viewpoints_db
      self.viewpoints.select do |viewpoint|
        feed=viewpoint.feed
        if feed.blank?
          false
        else
          feed.hot_viewpoint == viewpoint
        end
      end
    end

  end

  module FeedMethods
    def self.included(base)
      base.has_many :viewpoints
      base.has_many :memoed_viewpoints,:class_name=>"Viewpoint",:conditions=>"viewpoints.memo is not null",:order=>'vote_score desc'
      base.has_many :memoed_users_db,:through=>:viewpoints,:source=>:user,
        :order=>"viewpoints.vote_score desc"
    end

    def viewpoint_of(user)
      self.viewpoints.find_by_user_id(user.id)
    end

    def viewpoint_by?(user)
      !viewpoint_of(user).blank?
    end
    
    # 创建对 feed 的观点
    def create_or_update_viewpoint(user,content)
      viewpoint = self.viewpoint_of(user)
      if viewpoint.blank?
        viewpoint = Viewpoint.create(:feed=>self,:user=>user,:memo=>content)
        viewpoint.record_editer(user)
      elsif viewpoint.memo != content
        viewpoint.add_memo(content)
        viewpoint.record_editer(user)
      end
      viewpoint
    end

    def has_viewpoint?
      !self.viewpoints.blank?
    end

    def hot_viewpoint
      viewpoint = self.viewpoints.first
      return if viewpoint.vote_score <= 0
      return viewpoint
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

  end

  include ViewpointComment::ViewpointMethods
  include ViewpointVote::ViewpointMethods
  include ViewpointDraft::ViewpointMethods
  include UserLog::ViewpointMethods
  include ViewpointSpamMark::ViewpointMethods
  include Atme::AtableMethods
  include Atme::ViewpointMethods
  include ViewpointRevision::ViewpointMethods
end
