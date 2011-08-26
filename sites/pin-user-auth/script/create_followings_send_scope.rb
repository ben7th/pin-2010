feeds = Feed.find(:all,:conditions=>"feeds.send_status = '#{SendScope::FOLLOWINGS}' ")
feeds_count = feeds.length

def Feed.record_timestamps
  false
end

feeds.each_with_index do |feed,index|
  p "正在处理 #{index+1}/#{feeds_count}"

  def feed.record_timestamps
    false
  end
  feed.send_status = Feed::SendStatus::SCOPED
  feed.save

  scope = feed.send_scopes.find_by_param(SendScope::FOLLOWINGS)
  if scope.blank?
    feed.send_scopes.create(:param=>SendScope::FOLLOWINGS)
  end

end

