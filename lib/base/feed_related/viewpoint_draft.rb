class ViewpointDraft < UserAuthAbstract
  belongs_to :feed
  belongs_to :user
  validates_presence_of :feed
  validates_presence_of :user
  validates_uniqueness_of :feed_id, :scope => :user_id

  module FeedMethods
    def self.included(base)
      base.has_many :viewpoint_drafts
    end

    def viewpoint_draft_of(user)
      self.viewpoint_drafts.find_by_user_id(user.id)
    end

    def has_viewpoint_draft_of?(user)
      !viewpoint_draft_of(user).blank?
    end

    def viewpoint_draft_content_of(user)
      vd = viewpoint_draft_of(user)
      return if vd.blank?
      vd.content
    end
    
    def save_viewpoint_draft(user,content)
      vd = viewpoint_draft_of(user)
      if vd.blank?
        ViewpointDraft.create(:feed=>self,:user=>user,:content=>content)
      else
        vd.update_attribute(:content,content)
      end
    end
  end

  module ViewpointMethods
    def self.included(base)
      base.after_create :remove_viewpoint_draft
      base.after_update :remove_viewpoint_draft_on_update
    end

    def remove_viewpoint_draft
      vd = self.feed.viewpoint_draft_of(self.user)
      vd.destroy unless vd.blank?
      return true
    end

    def remove_viewpoint_draft_on_update
      return true if self.changes["memo"].blank?
      remove_viewpoint_draft
    end
  end
end
