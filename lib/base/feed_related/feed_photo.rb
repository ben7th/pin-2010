class FeedPhoto < UserAuthAbstract
  belongs_to :feed
  belongs_to :photo

  validates_presence_of :feed
  validates_presence_of :photo

  module FeedMethods
    def self.included(base)
      base.has_many :feed_photos
      base.has_many :photos, :through=>:feed_photos
    end
  end

  module PhotoMethods
    def self.included(base)
      base.has_many :feed_photos
      base.has_many :feeds, :through=>:feed_photos
    end
  end
end
