Feed.transaction do
  feeds = Feed.all
  count = feeds.length
  feeds.each_with_index do |feed,index|
    p "正在转换 #{index+1}/#{count}"
    creator = EmailActor.get_user_by_email(feed.email)
    if creator && feed.content
      feed.creator_id = creator.id
      feed.save!
    end
  end
end