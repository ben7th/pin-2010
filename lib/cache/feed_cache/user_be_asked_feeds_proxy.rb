class UserBeAskedFeedsProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_be_asked_feeds"
  end

  def xxxs_ids_db
    @user.be_asked_feeds_db.map{|feed|feed.id}
  end

  def self.rules
    {
      :class => TodoUser ,
      :after_create => Proc.new {|todo_user|
        user = todo_user.user
        feed = todo_user.todo.feed
        if todo_user.memo.nil?
          UserBeAskedFeedsProxy.new(user).add_to_cache(feed.id)
        end
      },
      :after_update => Proc.new {|todo_user|
        user = todo_user.user
        todo = todo_user.todo
        next if user.blank? || todo.blank?
        feed = todo.feed
        next if feed.blank?
        UserBeAskedFeedsProxy.new(user).remove_from_cache(feed.id)
        if todo_user.memo.nil?
          UserBeAskedFeedsProxy.new(user).add_to_cache(feed.id)
        end
      },
      :after_destroy => Proc.new {|todo_user|
        user = todo_user.user
        todo = todo_user.todo
        next if user.blank? || todo.blank?
        feed = todo.feed
        next if feed.blank?
        UserBeAskedFeedsProxy.new(user).remove_from_cache(feed.id)
      }
    }
  end

  def self.funcs
    {
      :class  => User ,
      :be_asked_feeds => Proc.new {|user|
        UserBeAskedFeedsProxy.new(user).get_models(Feed)
      }
    }
  end
end
