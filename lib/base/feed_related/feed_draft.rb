class FeedDraft < UserAuthAbstract
  FORMAT_HTML = "html"
  FORMAT_MARKDOWN = "markdown"

  belongs_to :user
  validates_presence_of :draft_token
  validates_presence_of :user
  validates_presence_of :text_format,:if => Proc.new { |feed_draft| !feed_draft.content.blank? }

  module UserMethods
    def self.included(base)
      base.has_many :feed_drafts,:order=>"feed_drafts.updated_at desc"
    end
  end
end
