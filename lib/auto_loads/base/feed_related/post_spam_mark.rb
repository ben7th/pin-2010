class PostSpamMark < UserAuthAbstract
  belongs_to :post
  belongs_to :user
  validates_presence_of :post
  validates_presence_of :user
  validates_uniqueness_of :post_id, :scope => :user_id

  EFFECT_COUNT = 5

  module PostMethods
    def self.included(base)
      base.has_many :spam_marks,:class_name=>"PostSpamMark",
        :foreign_key=>:post_id
    end

    def spam_mark_score
      self.spam_marks.map{|sm|sm.count}.sum
    end

    def spam_mark_effect?
      spam_mark_score >= PostSpamMark::EFFECT_COUNT
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
      count = PostSpamMark::EFFECT_COUNT if user.is_admin_user?
      PostSpamMark.create(:post=>self,:user=>user,:count=>count)
    end

  end
end
