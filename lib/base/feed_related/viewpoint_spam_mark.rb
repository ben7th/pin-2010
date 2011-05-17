class ViewpointSpamMark < UserAuthAbstract
  belongs_to :viewpoint,:class_name=>"TodoUser"
  belongs_to :user
  validates_presence_of :viewpoint
  validates_presence_of :user
  validates_uniqueness_of :viewpoint_id, :scope => :user_id

  EFFECT_COUNT = CoreService.find_setting_by_project_name(CoreService::USER_AUTH)["spam_mark_effect_count"]

  module TodoUserMethods
    def self.included(base)
      base.has_many :spam_marks,:class_name=>"ViewpointSpamMark",
        :foreign_key=>:viewpoint_id
    end

    def spam_mark_score
      self.spam_marks.map{|sm|sm.count}.sum
    end

    def spam_mark_effect?
      spam_mark_score >= ViewpointSpamMark::EFFECT_COUNT
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
      count = ViewpointSpamMark::EFFECT_COUNT if user.is_admin_user?
      ViewpointSpamMark.create(:viewpoint=>self,:user=>user,:count=>count)
    end

  end
end
