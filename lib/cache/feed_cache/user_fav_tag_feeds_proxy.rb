class UserFavTagFeedsProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_fav_tag_feeds"
  end

  def xxxs_ids_db
    @user.fav_tag_feeds_db.map{|x| x.id}
  end

  # 关注 关键词
  def self.syn_cache_on_fav_tag(tag,user)
    add_ids = tag.feeds.map{|feed|feed.id}
    proxy = self.new(user)
    ids = proxy.xxxs_ids
    ids=(ids+add_ids).uniq.sort{|x,y|y<=>x}
    proxy.send(:xxxs_ids_rediscache_save,ids)
  end

  # 取消关注 关键词
  def self.syn_cache_on_unfav_tag(tag,user)
    remove_ids = tag.feeds.select do |feed|
      (feed.tags & user.fav_tags - [tag]).blank?
    end.map{|feed|feed.id}

    proxy = self.new(user)
    ids = proxy.xxxs_ids
    ids=(ids-remove_ids).uniq.sort{|x,y|y<=>x}
    proxy.send(:xxxs_ids_rediscache_save,ids)
  end

  # 主题 增加 关键词
  def self.syn_cache_on_create_feed_tag(feed,tag)
    tag.fav_users.each do |user|
      proxy = self.new(user)
      ids = proxy.xxxs_ids
      ids = (ids + [feed.id]).uniq.sort{|x,y|y<=>x}
      proxy.send(:xxxs_ids_rediscache_save,ids)
    end
  end

  # 主题 删除 关键词
  def self.syn_cache_on_destroy_feed_tag(feed,tag)
    tag.fav_users.each do |user|
      if (feed.tags & user.fav_tags - [tag]).blank?
        proxy = self.new(user)
        ids = proxy.xxxs_ids
        ids = (ids-[feed.id]).uniq.sort{|x,y|y<=>x}
        proxy.send(:xxxs_ids_rediscache_save,ids)
      end
    end
  end

  def self.rules
    [
      {
        :class => TagFav ,
        :after_create => Proc.new {|tag_fav|
          tag = tag_fav.tag
          user = tag_fav.user
          UserFavTagFeedsProxy.syn_cache_on_fav_tag(tag,user)
        },
        :after_destroy => Proc.new {|tag_fav|
          tag = tag_fav.tag
          user = tag_fav.user
          UserFavTagFeedsProxy.syn_cache_on_unfav_tag(tag,user)
        }
      },
      {
        :class => FeedTag,
        :after_create => Proc.new {|feed_tag|
          feed = feed_tag.feed
          tag = feed_tag.tag
          UserFavTagFeedsProxy.syn_cache_on_create_feed_tag(feed,tag)
        },
        :after_destroy => Proc.new {|feed_tag|
          feed = feed_tag.feed
          tag = feed_tag.tag
          UserFavTagFeedsProxy.syn_cache_on_destroy_feed_tag(feed,tag)
        }
      }
    ]
  end


  def self.funcs
    {
      :class  => User ,
      :fav_tag_feeds => Proc.new {|user|
        UserFavTagFeedsProxy.new(user).get_models(Feed)
      }
    }
  end
end

