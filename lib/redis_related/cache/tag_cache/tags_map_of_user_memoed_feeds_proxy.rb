class TagsMapOfUserMemoedFeedsProxy
  def initialize(user)
    @user = user
    @key = "tags_map_of_user_#{@user.id}_memoed_feeds"
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
        inner join viewpoints on feed_tags.feed_id = viewpoints.feed_id
        inner join feeds on viewpoints.feed_id = feeds.id
        where viewpoints.user_id = #{@user.id} and feeds.hidden = false
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
      base.after_create :change_tags_map_of_memoed_feeds_cache_on_create
      base.after_destroy :change_tags_map_of_memoed_feeds_cache_on_destroy
    end

    def change_tags_map_of_memoed_feeds_cache_on_create
      tag = self.tag
      return true if tag.is_default?

      self.feed.memoed_users.each do |user|
        TagsMapOfUserMemoedFeedsProxy.new(user).related_increase(tag)
      end
      return true
    end

    def change_tags_map_of_memoed_feeds_cache_on_destroy
      tag = self.tag
      return true if tag.is_default?

      self.feed.memoed_users.each do |user|
        TagsMapOfUserMemoedFeedsProxy.new(user).related_decrease(tag)
      end
      return true
    end
  end

  module ViewpointMethods
    def self.included(base)
      base.after_create :change_tags_map_of_memoed_feeds_cache_on_create
    end

    def change_tags_map_of_memoed_feeds_cache_on_create
      user = self.user
      self.feed.tags.each do |tag|
        next if tag.is_default?
        TagsMapOfUserMemoedFeedsProxy.new(user).related_increase(tag)
      end
      return true
    end
  end

  module UserMethods

    # 返回关于用户参与的主题包括的tag统计的hash数组
    def tags_map_of_memoed_feeds
      ab = _tags_items_of_memoed_feeds
      ab.map do |item|
        tag = Tag.get_tag(item["name"],item["namespace"])
        count = item["count"]
        {:tag=>tag,:count=>count}
      end
    end

    # 返回用户参与的主题包括的tag，按出现次数排序，出现多的排前面
    def tags_of_memoed_feeds
      ab = _tags_items_of_memoed_feeds
      ab.map{|item|Tag.get_tag(item["name"],item["namespace"])}
    end

    # 根据用户参与的主题包括的tag，来给用户推荐可能可以参与的主题
    def recommend_feeds(count=nil)
      except_feeds = (memoed_feeds | created_feeds)

      recommend_feeds = tags_of_memoed_feeds.map do |tag|
        tag.feeds.normal - except_feeds
      end.flatten.sort{|x,y|x.viewpoints.count<=>y.viewpoints.count}

      return recommend_feeds if count.blank?
      return recommend_feeds[0..count-1]
    end



    private
    def _tags_items_of_memoed_feeds
      ActiveRecord::Base.connection.select_all(%`
        select tags.name,tags.namespace,count(*) count from tags
        inner join feed_tags on tags.id = feed_tags.tag_id
        inner join viewpoints on feed_tags.feed_id = viewpoints.feed_id
        inner join feeds on viewpoints.feed_id = feeds.id
        where viewpoints.user_id = #{self.id} and feeds.hidden = false
          and tags.name <> "#{Tag::DEFAULT}"
        group by tags.id
        order by count desc
        `)
    end
  end
end
