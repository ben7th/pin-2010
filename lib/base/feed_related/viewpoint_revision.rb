class ViewpointRevision < UserAuthAbstract
  belongs_to :viewpoint
  belongs_to :user

  validates_presence_of :viewpoint
  validates_presence_of :user
  validates_presence_of :content

  def memo
    self.content
  end

  def prev
    vr_ids = self.viewpoint.viewpoint_revision_ids
    prve_id = vr_ids[vr_ids.index(self.id)+1]
    unless prve_id.blank?
      return ViewpointRevision.find_by_id(prve_id)
    end
    return nil
  end

  def rollback(editor)
    viewpoint = self.viewpoint

    return if editor != viewpoint.user
    return if viewpoint.viewpoint_revisions.first == self

    revision_count = viewpoint.viewpoint_revisions.reverse.index(self) + 1
    viewpoint.add_memo(self.content)
    viewpoint.record_editer(editor,"回滚到 版本#{revision_count}")
    viewpoint
  end


  module ViewpointMethods
    def self.included(base)
      base.has_many :viewpoint_revisions,:order=>"viewpoint_revisions.id desc"
    end

    def record_editer(editer,message="")
      ViewpointRevision.create(:viewpoint=>self,:user=>editer,
        :content=>self.memo,:message=>message)
    end
  end
end
