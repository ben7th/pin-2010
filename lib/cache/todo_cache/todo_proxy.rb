module TodoProxy
  module TodoUserMethods
    def self.included(base)
      base.after_create :add_todo_id_to_user_assigned_todos_cache_on_create
      base.after_destroy :remove_todo_id_from_user_assigned_todos_cache_on_destroy
      base.after_update :change_user_status_todos_cache_on_change_status
      base.after_update :change_user_change_todos
    end

    def add_todo_id_to_user_assigned_todos_cache_on_create
      UserAssignedTodosProxy.new(self.user).add_to_cache(self.todo_id)
      UserReadyTodosProxy.new(self.user).add_to_cache(self.todo_id)
      return true
    end

    def remove_todo_id_from_user_assigned_todos_cache_on_destroy
      UserAssignedTodosProxy.new(self.user).remove_from_cache(self.todo_id)
      _remove_from_status_todos_cache
      return true
    end

    def change_user_status_todos_cache_on_change_status
      status_array = self.changes["status"]
      # 此时状态没有改变，直接返回
      return true if status_array.blank?
      new_status = status_array.last
      _remove_from_status_todos_cache
      case new_status
      when TodoUser::STATUS_READY
        UserReadyTodosProxy.new(self.user).add_to_cache(self.todo_id)
      when TodoUser::STATUS_DOING
        UserDoingTodosProxy.new(self.user).add_to_cache(self.todo_id)
      when TodoUser::STATUS_DONE
        UserDoneTodosProxy.new(self.user).add_to_cache(self.todo_id)
      when TodoUser::STATUS_DROP
        UserDropTodosProxy.new(self.user).add_to_cache(self.todo_id)
      end
      return true
    end

    def change_user_change_todos
      status_change = self.changes["status"]
      memo_change = self.changes["memo"]
      if !status_change.blank? || !memo_change.blank?
        add_todo_to_user_change_status_todos
      end
    end

    # 此时状态改变,将状态改变的todo增加到用户的“状态改变的todos”列表中
    def add_todo_to_user_change_status_todos
      users = self.todo.executers - [self.user]
      users.each do |user|
        UserTodosChangeStatusProxy.new(user).add(self.todo)
      end
    end

    def _remove_from_status_todos_cache
      UserReadyTodosProxy.new(self.user).remove_from_cache(self.todo_id)
      UserDoingTodosProxy.new(self.user).remove_from_cache(self.todo_id)
      UserDoneTodosProxy.new(self.user).remove_from_cache(self.todo_id)
      UserDropTodosProxy.new(self.user).remove_from_cache(self.todo_id)
    end
  end

  module UserMethods
    def assigned_todos
      todo_ids = UserAssignedTodosProxy.new(self).xxxs_ids
      todo_ids.map{|id|Todo.find_by_id(id)}.compact
    end

    def status_todos(status)
      case status
      when TodoUser::STATUS_READY
        ready_todos
      when TodoUser::STATUS_DOING
        doing_todos
      when TodoUser::STATUS_DONE
        done_todos
      when TodoUser::STATUS_DROP
        drop_todos
      end
    end

    def ready_todos
      todo_ids = UserReadyTodosProxy.new(self).xxxs_ids
      todo_ids.map{|id|Todo.find_by_id(id)}.compact
    end

    def doing_todos
      todo_ids = UserDoingTodosProxy.new(self).xxxs_ids
      todo_ids.map{|id|Todo.find_by_id(id)}.compact
    end

    def done_todos
      todo_ids = UserDoneTodosProxy.new(self).xxxs_ids
      todo_ids.map{|id|Todo.find_by_id(id)}.compact
    end

    def drop_todos
      todo_ids = UserDropTodosProxy.new(self).xxxs_ids
      todo_ids.map{|id|Todo.find_by_id(id)}.compact
    end

    def assigned_todos_ids
      UserAssignedTodosProxy.new(self).xxxs_ids
    end

    def drop_tods_ids
      UserDropTodosProxy.new(self).xxxs_ids
    end

    def undrop_assigned_todos
      undrop_ids = assigned_todos_ids - drop_tods_ids
      undrop_ids.map{|id|Todo.find_by_id(id)}.compact
    end

  end
end
