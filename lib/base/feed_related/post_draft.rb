class PostDraft < UserAuthAbstract
  FORMAT_HTML = "html"
  FORMAT_MARKDOWN = "markdown"

  belongs_to :user
  validates_presence_of :draft_token
  validates_presence_of :user
  validates_presence_of :text_format,:if => Proc.new { |post_draft| !post_draft.detail.blank? }

  def photo_tmps
   self.photo_names.split(",").map do |name|
     PhotoTmp.find(name)
   end
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
