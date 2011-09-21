def Post.record_timestamps
  false
end

feeds = Feed.find(:all,:order=>"id asc")
count = feeds.length
feeds.each_with_index do |feed,index|
  p "正在处理 feed_#{feed.id} #{index+1}/#{count}"

  title = feed.attributes["content"]
  main_post = feed.main_post

  def main_post.record_timestamps
    false
  end

  main_post.title = title
  main_post.save
end
