class PostDraft < UserAuthAbstract
  belongs_to :feed
  belongs_to :user
  validates_presence_of :feed
  validates_presence_of :user
  validates_uniqueness_of :feed_id, :scope => :user_id

  module FeedMethods
    def self.included(base)
      base.has_many :post_drafts
    end

    def post_draft_of(user)
      self.post_drafts.find_by_user_id(user.id)
    end

    def has_post_draft_of?(user)
      !post_draft_of(user).blank?
    end

    def post_draft_content_of(user)
      vd = post_draft_of(user)
      return if vd.blank?
      vd.content
    end
    
    def save_post_draft(user,content)
      vd = post_draft_of(user)
      if vd.blank?
        PostDraft.create(:feed=>self,:user=>user,:content=>content)
      else
        vd.update_attribute(:content,content)
      end
    end
  end

  module PostMethods
    def self.included(base)
      base.after_create :remove_post_draft
      base.after_update :remove_post_draft_on_update
    end

    def remove_post_draft
      vd = self.feed.post_draft_of(self.user)
      vd.destroy unless vd.blank?
      return true
    end

    def remove_post_draft_on_update
      return true if self.changes["detail"].blank?
      remove_post_draft
    end
  end
end
