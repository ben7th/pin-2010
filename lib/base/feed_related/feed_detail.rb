class FeedDetail < UserAuthAbstract
  belongs_to :feed
  validates_presence_of :feed
  validates_presence_of :content

  module FeedMethods
    def self.included(base)
      base.has_one :feed_detail
    end

    def create_or_update_detail(content)
      fd = self.feed_detail
      return FeedDetail.create(:feed=>self,:content=>content) if fd.blank?
      fd.update_attribute(:content,content)
    end
  end

end
