class TagDetailRevision < UserAuthAbstract
  belongs_to :tag
  belongs_to :user

  validates_presence_of :tag
  validates_presence_of :user
  validates_presence_of :detail
  
  def prev
    ids = self.tag.tag_detail_revision_ids
    prve_id = ids[ids.index(self.id)+1]
    unless prve_id.blank?
      return TagDetailRevision.find_by_id(prve_id)
    end
    return nil
  end

  def rollback_detail(user)
    tag = self.tag
    return false unless user.is_admin_user?
    return false if tag.tag_detail_revisions.first == self
    return false if tag.detail == self.detail

    revision_count = tag.tag_detail_revisions.reverse.index(self) + 1
    tag.update_attribute(:detail,self.detail)
    tag.record_detail_editor(self.detail,user,"回滚到 版本#{revision_count}")
    return true
  end

  module TagMethods
    def self.included(base)
      base.has_many :tag_detail_revisions,:order=>"tag_detail_revisions.id desc"
    end

    def last_editor
      revisions = self.tag_detail_revisions
      return if revisions.blank?

      revisions.first.user
    end

    def record_detail_editor(detail,editor,message=nil)
      self.tag_detail_revisions.create(:user=>editor,:detail=>detail,:message=>message)
    end

  end
end
