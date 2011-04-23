# 用户被指派的 todo
class UserAssignedTodosProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_assigned_todos"
  end

  def xxxs_ids_db
    @user.assigned_todos_db.map{|todo|todo.id}
  end

  def change_sort(todos_ids)
    reset_cache(todos_ids)
  end

  def self.rules
    {
      :class => TodoUser ,
      :after_create => Proc.new {|todo_user|
        user = todo_user.user
        todo = todo_user.todo
        next if user.blank? || todo.blank?
        UserAssignedTodosProxy.new(user).add_to_cache(todo.id)
      },
      :after_destroy => Proc.new {|todo_user|
        user = todo_user.user
        todo = todo_user.todo
        next if user.blank? || todo.blank?
        UserAssignedTodosProxy.new(user).remove_from_cache(todo.id)
      },
      :after_update => Proc.new{|todo_user|
        UserAssignedTodosProxy.change_user_status_todos_cache_on_change_status(todo_user)
        UserAssignedTodosProxy.change_user_change_todos(todo_user)
      }
    }
  end

  def self.funcs
    {
      :class  => User ,
      :assigned_todos => Proc.new {|user|
        UserAssignedTodosProxy.new(user).get_models(Todo)
      },
      :assigned_todos_ids => Proc.new{|user|
        UserAssignedTodosProxy.new(user).xxxs_ids
      },
      :undrop_assigned_todos => Proc.new{|user|
        undrop_ids = user.assigned_todos_ids - user.drop_tods_ids
        undrop_ids.map{|id|Todo.find_by_id(id)}.compact.uniq
      },
      :status_todos => Proc.new{|user,status|
        case status
        when TodoUser::STATUS_READY
          user.ready_todos
        when TodoUser::STATUS_DOING
          user.doing_todos
        when TodoUser::STATUS_DONE
          user.done_todos
        when TodoUser::STATUS_DROP
          user.drop_todos
        end
      }
    }
  end

  def self.change_user_status_todos_cache_on_change_status(todo_user)
    status_array = todo_user.changes["status"]
    # 此时状态没有改变，直接返回
    return true if status_array.blank?
    new_status = status_array.last
    remove_from_status_todos_cache(todo_user)
    case new_status
    when TodoUser::STATUS_READY
      UserReadyTodosProxy.new(todo_user.user).add_to_cache(todo_user.todo_id)
    when TodoUser::STATUS_DOING
      UserDoingTodosProxy.new(todo_user.user).add_to_cache(todo_user.todo_id)
    when TodoUser::STATUS_DONE
      UserDoneTodosProxy.new(todo_user.user).add_to_cache(todo_user.todo_id)
    when TodoUser::STATUS_DROP
      UserDropTodosProxy.new(todo_user.user).add_to_cache(todo_user.todo_id)
    end
  end

  def self.change_user_change_todos(todo_user)
    status_change = todo_user.changes["status"]
    memo_change = todo_user.changes["memo"]
    return if status_change.blank? && memo_change.blank?

    users = todo_user.todo.executers - [todo_user.user]
    users.each do |user|
      UserTodosChangeStatusProxy.new(user).add(todo_user.todo)
    end
  end

  def self.remove_from_status_todos_cache(todo_user)
    UserReadyTodosProxy.new(todo_user.user).remove_from_cache(todo_user.todo_id)
    UserDoingTodosProxy.new(todo_user.user).remove_from_cache(todo_user.todo_id)
    UserDoneTodosProxy.new(todo_user.user).remove_from_cache(todo_user.todo_id)
    UserDropTodosProxy.new(todo_user.user).remove_from_cache(todo_user.todo_id)
  end
end
