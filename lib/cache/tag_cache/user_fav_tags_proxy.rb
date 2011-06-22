# 用户收藏了哪些tag的向量缓存
class UserFavTagsProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{user.id}_fav_tags"
  end

  def xxxs_ids_db
    @user.fav_tags_db.map{|tag|tag.id}
  end

  def self.rules
    {
      :class => TagFav ,
      :after_create => Proc.new {|tag_fav|
        UserFavTagsProxy.new(tag_fav.user).add_to_cache(tag_fav.tag_id)
      },
      :after_destroy => Proc.new {|tag_fav|
        UserFavTagsProxy.new(tag_fav.user).remove_from_cache(tag_fav.tag_id)
      }
    }
  end

  def self.funcs
    {
      :class  => User ,
      :fav_tags => Proc.new {|user|
        UserFavTagsProxy.new(user).get_models(Tag)
      }
    }
  end
end
