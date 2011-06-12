class FeedRevision < UserAuthAbstract
  belongs_to :feed
  belongs_to :user

  validates_presence_of :feed
  validates_presence_of :user
  validates_presence_of :title

  def tag_ids
    ActiveSupport::JSON.decode(tag_ids_json)
  end

  def prev
    fr_ids = self.feed.feed_revision_ids
    prve_id = fr_ids[fr_ids.index(self.id)+1]
    unless prve_id.blank?
      return FeedRevision.find_by_id(prve_id)
    end
    return nil
  end

  def rollback(editor)
    feed = self.feed

    return unless editor.is_admin?
    return if feed.locked?
    return if feed.feed_revisions.first == self

    revision_count = feed.feed_revisions.reverse.index(self) + 1
    content = self.title
    detail_content = self.detail
    tag_ids = self.tag_ids

    # 回滚标题和标签
    feed.update_attributes(:content=>content,:tag_ids=>tag_ids)
    # 回滚正文
    feed.create_or_update_detail(detail_content) unless detail_content.blank?
    # 建立新 revision

    feed.record_editer(editor,"回滚到 版本#{revision_count}")
    feed.reload
    feed
  end

  module FeedMethods
    def self.included(base)
      base.has_many :feed_revisions,:order=>"feed_revisions.id desc"
      base.has_many :edited_users,:through=>:feed_revisions,:source=>:user,
        :order=>"feed_revisions.id desc"
    end

    def last_edited_time
      fc = self.feed_revisions.first
      return self.updated_at if fc.blank?
      fc.updated_at
    end

    def last_edited_user
      edited_users.first
    end

    def record_editer(editer,message="")
      self.reload
      FeedRevision.create(:feed=>self,:user=>editer,:tag_ids_json=>self.tag_ids.to_json,
        :title=>self.content,:detail=>self.detail_content,:message=>message)
    end
  end

  include UserLog::FeedRevisionMethods
  include FeedTag::FeedRevisionMethods
  include FeedLucene::FeedRevisionMethods
  include Atme::FeedRevisionMethods
end