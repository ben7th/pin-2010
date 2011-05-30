ActiveRecord::Base.transaction do
  todo_users = TodoUser.all

  dirty_todo_users = todo_users.select{|todo_user|todo_user.feed.blank?}
  count = dirty_todo_users.length
  dirty_todo_users.each_with_index do |tu,index|
    p "正在处理 #{index+1}/#{count}"
    todo = tu.todo
    unless todo.blank?
      todo.todo_items.each{|ti|ti.destroy}
      todo.destroy
    end
    tu.destroy
  end
end