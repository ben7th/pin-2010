class TagsMapOfUserCreatedFeedsProxy
  def initialize(user)
    @user = user
    @key = "tags_map_of_user_#{@user.id}_created_feeds"
    @redis_set = RedisCacheSortedSet.new(@key)
  end

  def map
    syn_cache_when_unexists
    @redis_set.lists
  end

  def syn_cache_when_unexists
    syn_cache unless @redis_set.exists?
  end

  def syn_cache
    ab = ActiveRecord::Base.connection.select_all(%`
        select tags.name,tags.namespace,count(*) count from tags
        inner join feed_tags on tags.id = feed_tags.tag_id
        inner join feeds on feed_tags.feed_id = feeds.id
        where feeds.creator_id = #{@user.id} and feeds.hidden = false
          and tags.name <> "#{Tag::DEFAULT}"
        group by tags.id
      `)
    @redis_set.touch
    ab.each do |item|
      full_name = Tag.full_name_str(item["name"],item["namespace"])
      count = item["count"]
      @redis_set.set_score(full_name,count)
    end
  end

  def related_increase(tag)
    unless @redis_set.exists?
      return syn_cache
    end
    @redis_set.increase(tag.full_name)
  end

  def related_decrease(tag)
    unless @redis_set.exists?
      return syn_cache
    end
    @redis_set.decrease(tag.full_name)
  end

  module FeedTagMethods
    def self.included(base)
      base.after_create :change_tags_map_of_created_feeds_cache_on_create
      base.after_destroy :change_tags_map_of_created_feeds_cache_on_destroy
    end

    def change_tags_map_of_created_feeds_cache_on_create
      creator = self.feed.creator
      tag = self.tag
      return true if tag.is_default?
      
      TagsMapOfUserCreatedFeedsProxy.new(creator).related_increase(tag)
    end

    def change_tags_map_of_created_feeds_cache_on_destroy
      creator = self.feed.creator
      tag = self.tag
      return true if tag.is_default?

      TagsMapOfUserCreatedFeedsProxy.new(creator).related_decrease(tag)
    end
  end

  module UserMethods
    # 暂时直接查数据库，不用缓存
    def tags_map_of_created_feeds
      #TagsMapOfUserCreatedFeedsProxy.new(self).map
      tags_map_of_created_feeds_db
    end

    def tags_map_of_created_feeds_db
      ab = ActiveRecord::Base.connection.select_all(%`
        select tags.name,tags.namespace,count(*) count from tags
        inner join feed_tags on tags.id = feed_tags.tag_id
        inner join feeds on feed_tags.feed_id = feeds.id
        where feeds.creator_id = #{self.id} and feeds.hidden = false
          and tags.name <> "#{Tag::DEFAULT}"
        group by tags.id
        order by count desc
        `)
      ab.map do |item|
        tag = Tag.get_tag(item["name"],item["namespace"])
        count = item["count"]
        {tag=>count}
      end
    end
  end
end
