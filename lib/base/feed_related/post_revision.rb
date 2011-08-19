class PostRevision < UserAuthAbstract
  belongs_to :post
  belongs_to :user

  validates_presence_of :post
  validates_presence_of :user
  validates_presence_of :content

  def memo
    self.content
  end

  def prev
    vr_ids = self.post.post_revision_ids
    prve_id = vr_ids[vr_ids.index(self.id)+1]
    unless prve_id.blank?
      return PostRevision.find_by_id(prve_id)
    end
    return nil
  end

  def rollback(editor)
    post = self.post

    return if editor != post.user
    return if post.post_revisions.first == self

    revision_count = post.post_revisions.reverse.index(self) + 1
    post.add_memo(self.content)
    post.record_editer(editor,"回滚到 版本#{revision_count}")
    post
  end


  module PostMethods
    def self.included(base)
      base.has_many :post_revisions,:order=>"post_revisions.id desc"
    end

    def record_editer(editer,message="")
      PostRevision.create(:post=>self,:user=>editer,
        :content=>self.memo,:message=>message)
    end
  end
end
