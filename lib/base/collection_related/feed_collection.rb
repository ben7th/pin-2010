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

    def only_text_feeds
      Feed.find_by_sql(%`
        select * from feeds
        inner join feed_collections on feed_collections.feed_id = feeds.id
        inner join posts on posts.feed_id = feeds.id
          and posts.kind = '#{Post::KIND_MAIN}'
        left join post_photos on post_photos.post_id = posts.id
        where feed_collections.collection_id = #{self.id} 
          and post_photos.post_id is null
        order by feeds.id desc
        `).uniq
    end

    def only_photo_feeds
      Feed.find_by_sql(%`
        select * from feeds
        inner join feed_collections on feed_collections.feed_id = feeds.id
        inner join posts on posts.feed_id = feeds.id
          and posts.kind = '#{Post::KIND_MAIN}'
        inner join post_photos on post_photos.post_id = posts.id
        where feed_collections.collection_id = #{self.id}
          and posts.detail = ''
        order by feeds.id desc
        `).uniq
    end

    def with_photo_feeds
      Feed.find_by_sql(%`
        select * from feeds
        inner join feed_collections on feed_collections.feed_id = feeds.id
        inner join posts on posts.feed_id = feeds.id
          and posts.kind = '#{Post::KIND_MAIN}'
        inner join post_photos on post_photos.post_id = posts.id
        where feed_collections.collection_id = #{self.id}
        order by feeds.id desc
        `).uniq
    end

    def mixed_feeds
      Feed.find_by_sql(%`
        select * from feeds
        inner join feed_collections on feed_collections.feed_id = feeds.id
        inner join posts on posts.feed_id = feeds.id
          and posts.kind = '#{Post::KIND_MAIN}'
        inner join post_photos on post_photos.post_id = posts.id
        where feed_collections.collection_id = #{self.id}
          and posts.detail != ''
        order by feeds.id desc
        `).uniq
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
