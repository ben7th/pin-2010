class SpamMark < UserAuthAbstract
  belongs_to :feed
  belongs_to :user
  validates_presence_of :feed
  validates_presence_of :user
  validates_uniqueness_of :feed_id, :scope => :user_id

  EFFECT_COUNT = CoreService.find_setting_by_project_name(CoreService::USER_AUTH)["spam_mark_effect_count"]

  after_create :process_feed_to_hidden
  def process_feed_to_hidden
    self.feed.hide if self.feed.spam_mark_effect?
    return true
  end

  module FeedMethods
    def self.included(base)
      base.has_many :spam_marks
    end

    def spam_mark_score
      self.spam_marks.map{|sm|sm.count}.sum
    end

    def spam_mark_effect?
      spam_mark_score >= SpamMark::EFFECT_COUNT
    end

    def spam_mark_of(user)
      self.spam_marks.find_by_user_id(user.id)
    end

    def is_spam_marked_by?(user)
      !spam_mark_of(user).blank?
    end

    def add_spam_mark(user)
      return true if user.blank? || is_spam_marked_by?(user)
      count = 1
      count = SpamMark::EFFECT_COUNT if user.is_admin_user?
      SpamMark.create(:feed=>self,:user=>user,:count=>count)
    end

    def can_be_recovered_by?(user)
      user.is_admin_user? || (user == self.creator && !self.spam_mark_effect?)
    end

    def recover(user)
      return unless self.can_be_recovered_by?(user)
      self.show
      self.spam_marks.each{|sm|sm.destroy} if user.is_admin_user?
    end

  end
end
