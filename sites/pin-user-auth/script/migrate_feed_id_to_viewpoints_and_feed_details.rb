class SimpleTodo < UserAuthAbstract
  set_table_name "todos"
  belongs_to :feed
end

class SimpleiViewpoint < UserAuthAbstract
  set_table_name "viewpoints"

  def todo
    SimpleTodo.find_by_id(self.todo_id)
  end
end

class SimpleFeedDetail < UserAuthAbstract
  set_table_name "feed_details"

  def todo
    SimpleTodo.find_by_id(self.todo_id)
  end
end


ActiveRecord::Base.transaction do

  fds = SimpleFeedDetail.all
  fds_count = fds.count
  fds.each_with_index do |fd,index|
    p "正在处理 feed_details #{index+1}/#{fds_count}"

    todo = fd.todo
    next if todo.blank?
    feed = todo.feed
    next if feed.blank?

    fd.feed_id = feed.id
    fd.save_without_timestamping
  end

end


ActiveRecord::Base.transaction do
  vs = SimpleiViewpoint.all
  vs_count = vs.count
  vs.each_with_index do |v,index|
    p "正在处理 viewpoints #{index+1}/#{vs_count}"

    todo = v.todo
    next if todo.blank?
    feed = todo.feed
    next if feed.blank?

    v.feed_id = feed.id
    v.save_without_timestamping
  end
end


