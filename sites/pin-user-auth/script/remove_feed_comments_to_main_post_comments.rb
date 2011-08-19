class FeedComment < UserAuthAbstract
  belongs_to :feed
  belongs_to :user
end

feeds_ids = Feed.find_by_sql(%`
    select feeds.id
    from feeds
    order by feeds.id asc
  `).map{|feed|feed.id}

count = feeds_ids.length

feeds_ids.each_with_index do |id,index|
  p "正在处理 #{index+1}/#{count}"
  feed = Feed.find(id)

  feed_comments = FeedComment.find_all_by_feed_id(feed.id)
  feed_comments.each do |comment|
    post = feed.main_post
    post.create_comment(comment.user,comment.content)
  end
end