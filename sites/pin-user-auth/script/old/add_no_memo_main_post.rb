feeds_ids = Feed.find_by_sql(%`
    select feeds.id
    from feeds
    left join posts on posts.kind = "main"
      and
      posts.feed_id = feeds.id
      where posts.id is null
  `).map{|feed|feed.id}

count = feeds_ids.length

feeds_ids.each_with_index do |id,index|
  p "正在处理 #{index+1}/#{count}"

  feed = Feed.find(id)

  if feed.main_post.blank?
    feed.create_main_post("")
  end
end