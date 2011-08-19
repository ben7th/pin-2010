class UserHotPostsProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_hot_posts"
  end

  def xxxs_ids_db
    @user.top_posts_db.map{|post|post.id}
  end

  def self.add_to_cache_when_not_include(post)
    return unless post.vote_score > 0
    uhvp = UserHotPostsProxy.new(post.user)
    ids = uhvp.xxxs_ids
    unless ids.include?(post.id)
      ids.unshift(post.id)
      uhvp.send(:xxxs_ids_rediscache_save,ids)
    end
  end

  def self.remove_from_cache_when_include(post)
    uhvp = UserHotPostsProxy.new(post.user)
    ids = uhvp.xxxs_ids
    if ids.include?(post.id)
      ids.delete(post.id)
      uhvp.send(:xxxs_ids_rediscache_save,ids)
    end
  end

  def self.refresh_cache_on_edit_post(post)
    feed = post.feed
    if feed.hot_post == post
      uhvp = UserHotPostsProxy.new(post.user)
      ids = uhvp.xxxs_ids
      ids.delete(post.id)
      ids.unshift(post.id)
      uhvp.send(:xxxs_ids_rediscache_save,ids)
    end
  end

  def self.refresh_cache_on_post_vote(post)
    feed = post.feed
    if feed.hot_post == post
      
        UserHotPostsProxy.add_to_cache_when_not_include(post)

        second_post = feed.posts[1]
        if !second_post.blank?
          UserHotPostsProxy.remove_from_cache_when_include(second_post)
        end

    else
      
        UserHotPostsProxy.remove_from_cache_when_include(post)

        hot_post = feed.hot_post
        unless hot_post.blank?
          UserHotPostsProxy.add_to_cache_when_not_include(hot_post)
        end
        
    end
  end

  def self.rules
    {
      :class => Post,
      :after_update => Proc.new {|post|
        if !post.changes["memo"].blank?
          UserHotPostsProxy.refresh_cache_on_edit_post(post)
        elsif !post.changes["vote_score"].blank?
          UserHotPostsProxy.refresh_cache_on_post_vote(post)
        end
      }
    }
  end

  def self.funcs
    {
      :class => User,
      :top_posts => Proc.new{|user|
        UserHotPostsProxy.new(user).get_models(Post)
      }
    }
  end
end
