feeds = Feed.all
feeds_count = feeds.length

def Feed.record_timestamps
  false
end

feeds.each_with_index do |feed,index|
  p "正在处理 #{index+1}/#{feeds_count}"
  
  statuses = ["all-public","all-followings","private"]

  status_scopes = feed.send_scopes.select{|ss|statuses.include?(ss.param)}
  scope = status_scopes.first

  status = ""
  if scope.blank?
    status = Feed::SendStatus::SCOPED
  else
    status = scope.param
  end

  if status == "all-public"
    status = Feed::SendStatus::PUBLIC
  elsif status == "all-followings"
    status = Feed::SendStatus::FOLLOWINGS
  elsif status == "private"
    status = Feed::SendStatus::PRIVATE
  end

  def feed.record_timestamps
    false
  end

  feed.send_status = status
  bool = feed.save
  status_scopes.each{|ss|ss.destroy} if bool
end
