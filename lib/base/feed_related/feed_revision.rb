class FeedRevision < UserAuthAbstract
  belongs_to :feed
  belongs_to :user

  validates_presence_of :feed
  validates_presence_of :user
  validates_presence_of :title

  def content
    self.title
  end

  def detail_content
    self.detail
  end

  def tags
    tag_ids.map do |id|
      Tag.find_by_id(id)
    end.compact
  end

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

    # 有可能是被合并的标签
    tags = tag_ids.map{|tid|Tag.find(tid)}
    tags = tags.map{|tag|Tag.get_tag(tag.name,tag.namespace)}
    tag_ids = tags.map{|tag|tag.id}

    # 回滚标题和标签
    feed.update_attributes(:content=>content,:tag_ids=>tag_ids)
    # 回滚正文
    feed.update_detail_without_record_editor(detail_content)
    # 建立新 revision

    feed.record_editer(editor,"回滚到 版本#{revision_count}")
    feed.reload
    feed
  end

  module FeedMethods
    def last_edited_time
      fc = self.feed_revisions.first
      return self.updated_at if fc.blank?
      fc.updated_at
    end

    def last_edited_user
      edited_users.first
    end

    def record_editer(editer, message='')
      self.reload
      FeedRevision.create(
        :feed => self,
        :user => editer,
        :tag_ids_json => self.tag_ids.to_json,
        :title   => self.title,
        :detail  => self.detail,
        :message => message
      )
    end
  end

  include UserLog::FeedRevisionMethods
  include FeedLucene::FeedRevisionMethods
  include Atme::FeedRevisionMethods
end
