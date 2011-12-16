class FeedCollection < UserAuthAbstract
  belongs_to :feed
  belongs_to :collection
  validates_presence_of :feed
  validates_presence_of :collection
  validates_uniqueness_of :feed_id, :scope => :collection_id

  module FeedMethods
    def self.included(base)
      base.has_many :feed_collections,:dependent=>:destroy
      base.has_many :collections,:through=>:feed_collections,:source=>:collection
    end
  end

  module CollectionMethods
    def self.included(base)
      base.has_many :feed_collections,:dependent=>:destroy
      base.has_many :feeds_db,:through=>:feed_collections,:source=>:feed,
        :order=>"feeds.id desc"
    end

    def with_text_feeds_db
      Feed.find_by_sql(%`
        select feeds.* from feeds
        inner join feed_collections on feed_collections.feed_id = feeds.id
        inner join posts on posts.feed_id = feeds.id
          and posts.kind = '#{Post::KIND_MAIN}'
        where feed_collections.collection_id = #{self.id}
        and posts.detail != ''
        order by feeds.id desc
        `).uniq
    end

    def with_photo_feeds_db
      Feed.find_by_sql(%`
        select feeds.* from feeds
        inner join feed_collections on feed_collections.feed_id = feeds.id
        inner join posts on posts.feed_id = feeds.id
          and posts.kind = '#{Post::KIND_MAIN}'
        inner join post_photos on post_photos.post_id = posts.id
        where feed_collections.collection_id = #{self.id}
        order by feeds.id desc
        `).uniq
    end

    def mixed_feeds_db
      Feed.find_by_sql(%`
        select feeds.* from feeds
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

    def add_feed(feed)
      fc = FeedCollection.find_by_feed_id_and_collection_id(feed.id,self.id)
      return unless fc.blank?
      FeedCollection.create(:feed=>feed,:collection=>self)
    end

    def timeline(options={})
      Feed.mix_from_collections([self],options)
    end

    def feeds_limit(options={})
      Feed.option_filter(options) do |feature|
        case feature
        when "all"        then self.feed_ids
        when "text"       then self.with_text_feed_ids
        when "photo"      then self.with_photo_feed_ids
        when "text|photo" then self.mixed_feed_ids
        end
      end
    end
  end
end
