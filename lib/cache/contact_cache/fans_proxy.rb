class FansProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_fans_vector"
  end

  def xxxs_ids_db
    Contact.find(
      :all,
      :conditions=>"follow_user_id = #{@user.id}",
      :order=>"id desc"
    ).map{|c| c.user_id}
    # 读数据库
  end

  def self.rules
    {
      :class=>Contact,
      :after_create=>Proc.new{|contact|
        FansProxy.new(contact.follow_user).add_to_cache(contact.user_id)
      },
      :after_destroy=>Proc.new{|contact|
        FansProxy.new(contact.follow_user).remove_from_cache(contact.user_id)
      }
    }
  end

  def self.funcs
    {
      :class=>User,
      :fans=>Proc.new{|user|
        FansProxy.new(user).get_models(User)
      },
      :hotfans=>Proc.new{|user|
        user.fans
      }
    }
  end
end
