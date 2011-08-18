# tag 被哪些用户收藏的向量缓存
class TagFavUsersProxy < RedisBaseProxy
  def initialize(tag)
    @tag = tag
    @key = "tag_#{@tag.id}_fav_users"
  end

  def xxxs_ids_db
    @tag.fav_users_db.map{|user|user.id}
  end

  def self.rules
    {
      :class => TagFav ,
      :after_create => Proc.new {|tag_fav|
        TagFavUsersProxy.new(tag_fav.tag).add_to_cache(tag_fav.user_id)
      },
      :after_destroy => Proc.new {|tag_fav|
        TagFavUsersProxy.new(tag_fav.tag).remove_from_cache(tag_fav.user_id)
      }
    }
  end

  def self.funcs
    {
      :class => Tag ,
      :fav_users => Proc.new {|tag|
        TagFavUsersProxy.new(tag).get_models(User)
      },
      :fav_user_ids => Proc.new {|tag|
        TagFavUsersProxy.new(tag).xxxs_ids
      }
    }
  end
end
