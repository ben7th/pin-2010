class UserInboxLogProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_inbox_logs"
  end

  def xxxs_ids_db
    _id_list_from_followings_and_self_newer_than(nil)
  end

  def _id_list_from_followings_and_self_newer_than(newest_id)
    _id_list = @user.followings_and_self.map{|user|
      UserOutboxLogProxy.new(user).xxxs_ids
    }.flatten
    ids = _id_list.sort{|x,y|y<=>x}

    if !newest_id.nil?
      ids = ids.compact.select{|x| x > newest_id}
    end
    ids[0..199]
  end

  def xxxs_ids
    xxxs_ids_db
  end

  def self.rules
    {
      :class => UserLog,
      :after_create => Proc.new{|user_log|
        user_log_owner = user_log.user
        users = user_log_owner.hotfans + [user_log_owner]
        users.each do |user|
          UserInboxLogProxy.new(user).add_to_cache(user_log.id)
        end
      }
    }
  end

  def self.funcs
    {
      :class => User,
      :inbox_logs => Proc.new{|user|
        UserInboxLogProxy.new(user).get_models(UserLog)
      },
      :inbox_logs_limit => Proc.new{|user,count|
        ids = UserInboxLogProxy.new(user).xxxs_ids[0...count.to_i]
        ids.map{|id|UserLog.find_by_id(id)}.compact
      },
      :inbox_logs_more => Proc.new{|user,current_id,count|
        ids = UserInboxLogProxy.new(user).xxxs_ids
        ids = ids.select{|id|id.to_i < current_id.to_i}[0...count.to_i]
        ids.map{|id|UserLog.find_by_id(id)}.compact
      }
    }
  end
end
