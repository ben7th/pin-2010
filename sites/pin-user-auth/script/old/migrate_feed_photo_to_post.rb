def PostPhoto.record_timestamps
  false
end

pps = PostPhoto.find(:all,:order=>"id asc")
count = pps.length

pps.each_with_index do |pp,index|
  p "正在处理 post_photo_#{pp.id} #{index+1}/#{count}"

  def pp.record_timestamps
    false
  end
  feed = Feed.find(pp.feed_id)
  post = feed.main_post
  pp.post = post
  pp.save
end

