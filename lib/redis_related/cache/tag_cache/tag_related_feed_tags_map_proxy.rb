class TagRelatedFeedTagsMapProxy
  def initialize(tag)
    @tag = tag
    @key = "tag_#{tag.id}_related_feed_tags_map"
    @redis_set = RedisCacheSortedSet.new(@key)
  end

  # [{"苹果"=>2}, {"桃子"=>1}, {"关键词"=>1}, {"主人"=>1}, {"test"=>1}]
  def map
    syn_cache_when_unexists
    @redis_set.lists
  end

  def syn_cache
    ab = ActiveRecord::Base.connection.select_all(%`
        select count(*) c1,T2.name,T2.namespace from tags T1
        join feed_tags FT1 on T1.id = FT1.tag_id
        join feeds F1 on FT1.feed_id = F1.id
        join feed_tags FT2 on F1.id = FT2.feed_id
        join tags T2 on FT2.tag_id = T2.id
        where T1.id = #{@tag.id} and T1.id <> T2.id
           and T1.name <> "#{Tag::DEFAULT}" and T2.name <> "#{Tag::DEFAULT}"
        group by T2.id
        order by c1 desc
      `)
    @redis_set.touch
    ab.each do |item|
      full_name = Tag.full_name_str(item["name"],item["namespace"])
      @redis_set.set_score(full_name,item["c1"])
    end
  end

  def syn_cache_when_unexists
    syn_cache unless @redis_set.exists?
  end

  def related_increase(otag)
    unless @redis_set.exists?
      return syn_cache
    end
    @redis_set.increase(otag.full_name)
  end

  def realted_decrease(otag)
    unless @redis_set.exists?
      return syn_cache
    end
    @redis_set.decrease(otag.full_name)
  end

  def self.related_increase(old_tags,new_tag)
    old_tags.each do |otag|
      self.new(new_tag).related_increase(otag)
      self.new(otag).related_increase(new_tag)
    end
  end

  def self.related_decrease(old_tags,new_tag)
    old_tags.each do |otag|
      self.new(new_tag).realted_decrease(otag)
      self.new(otag).realted_decrease(new_tag)
    end
  end

  module TagMethods
    def related_feed_tags_map
      # [{"苹果"=>2}, {"桃子"=>1}, {"关键词"=>1}, {"主人"=>1}, {"test"=>1}]
      map = TagRelatedFeedTagsMapProxy.new(self).map
      map.map do |hash|
        tag_full_name = hash.keys.first
        tag = Tag.get_tag_by_full_name(tag_full_name)
        {:tag=>tag,:count=>hash[tag_full_name]}
      end
    end
  end

  module FeedTagMethods
    def self.included(base)
      base.after_create :change_related_feed_tags_map_cache_on_create
      base.after_destroy :change_related_feed_tags_map_cache_on_destroy
    end

    def change_related_feed_tags_map_cache_on_create
      return true if self.tag.is_default?

      old_tags = self.feed.tags.split(self.tag).first
      old_tags = old_tags.select{|otag|!otag.is_default?}
      return true if old_tags.blank?

      TagRelatedFeedTagsMapProxy.related_increase(old_tags,self.tag)
    end

    def change_related_feed_tags_map_cache_on_destroy
      return true if self.tag.is_default?

      old_tags = self.feed.tags.split(self.tag).first
      old_tags = old_tags.select{|otag|!otag.is_default?}
      return true if old_tags.blank?

      TagRelatedFeedTagsMapProxy.related_decrease(old_tags,self.tag)
    end
  end
end
