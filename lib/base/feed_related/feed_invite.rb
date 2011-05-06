class FeedInvite < UserAuthAbstract
  belongs_to :feed
  belongs_to :user
  belongs_to :creator,:class_name=>"User"
  validates_presence_of :feed
  validates_presence_of :user
  validates_presence_of :creator
  validates_uniqueness_of :feed_id, :scope => :user_id

  module FeedMethods
    def self.included(base)
      base.has_many :feed_invites,:order=>"feed_invites.id desc"
      base.has_many :be_invited_users_db, :through=>:feed_invites, :source=>:user,
        :order=>"feed_invites.id desc"
    end

    def be_invited_users
      be_invited_users_db
    end

    # 邀请用户参与话题
    def invite_users(users,operater)
      users.each do |user|
        FeedInvite.create(:feed=>self,:user=>user,:creator=>operater)
      end
    end

    # 取消 邀请参与话题的用户
    def cancel_invite_user(user)
      fi = self.feed_invites.find_by_user_id(user.id)
      fi.destroy unless fi.blank?
    end
  end

  module UserMethods
    def self.included(base)
      base.has_many :feed_invites,:order=>"feed_invites.id desc"
      base.has_many :be_invited_feeds_db, :through=>:feed_invites, :source=>:feed,
        :order=>"feed_invites.id desc"
    end
  end

  include UserBeInvitedFeedTipProxy::FeedInviteMethods
end
