class FeedCollection < UserAuthAbstract
  belongs_to :feed
  belongs_to :collection
  validates_presence_of :feed
  validates_presence_of :collection
  validates_uniqueness_of :feed_id, :scope => :collection_id

  module CollectionMethods
    def self.included(base)
      base.has_many :feed_collections
      base.has_many :feeds_db,:through=>:feed_collections,:source=>:feed
    end

    def feeds_for(user)
      self.feeds & user.in_feeds
    end

    def add_feed(feed,user)
      fc = FeedCollection.find_by_feed_id_and_collection_id(feed.id,self.id)
      return unless fc.blank?
      return unless user.in_collections.include?(self)

      FeedCollection.create(:feed=>feed,:collection=>self)
    end
  end
end
