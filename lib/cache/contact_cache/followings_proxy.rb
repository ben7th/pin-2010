class FollowingsProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_followings_vector"
  end

  def xxxs_ids_db
    Contact.find(
      :all,
      :conditions=>"user_id = #{@user.id}",
      :order=>"id desc"
    ).map{|c| c.follow_user_id} # 读数据库
  end

  def self.rules
    {
      :class=>Contact,
      :after_create=>Proc.new{|contact|
        FollowingsProxy.new(contact.user).add_to_cache(contact.follow_user_id)
      },
      :after_destroy=>Proc.new{|contact|
        FollowingsProxy.new(contact.user).remove_from_cache(contact.follow_user_id)
      }
    }
  end

  def self.funcs
    {
      :class=>User,
      :followings=>Proc.new{|user|
        FollowingsProxy.new(user).get_models(User)
      },
      :'following?'=>Proc.new{|user,follow_user|
        ids = FollowingsProxy.new(user).xxxs_ids
        ids.include?(follow_user.id)
      },
      :followings_and_self=>Proc.new{|user|
        user.followings + [user]
      },
      :following_user_ids=>Proc.new{|user|
        FollowingsProxy.new(user).xxxs_ids
      }
    }
  end
end
