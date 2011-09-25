class PostDraft < UserAuthAbstract
  FORMAT_HTML = "html"
  FORMAT_MARKDOWN = "markdown"

  belongs_to :user
  validates_presence_of :draft_token
  validates_presence_of :user
  validates_presence_of :text_format,:if => Proc.new { |post_draft| !post_draft.content.blank? }

  def photo_name_array
   self.photo_names.split(",")
  end

  def collection_id_array
    self.collection_ids.split(",")
  end

  module UserMethods
    def self.included(base)
      base.has_many :post_drafts,:order=>"post_drafts.updated_at desc"
    end
  end
end
