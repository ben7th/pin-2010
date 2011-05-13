ActiveRecord::Base.transaction do
  todo_users = TodoUser.find(:all,:conditions=>{:memo=>nil})
  count = todo_users.length
  todo_users.each_with_index do |todo_user,index|
    p "正在处理 #{index+1}/#{count}"
    todo_user.destroy
  end
end
