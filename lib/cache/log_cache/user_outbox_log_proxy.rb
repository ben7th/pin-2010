class UserOutboxLogProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_outbox_logs"
  end

  def xxxs_ids_db
    @user.outbox_logs_db.find(:all,:limit=>100).map{|x|x.id}
  end

  def self.rules
    {
      :class => UserLog,
      :after_create => Proc.new{|user_log|
        uolp = UserOutboxLogProxy.new(user_log.user)
        ids = uolp.xxxs_ids
        ids.unshift(user_log.id)
        ids = ids[0..99] if ids.length > 100
        uolp.send(:xxxs_ids_rediscache_save,ids)
      }
    }
  end

  def self.funcs
    {
      :class  => User ,
      :outbox_logs => Proc.new {|user|
        UserOutboxLogProxy.new(user).get_models(UserLog)
      }
    }
  end
end