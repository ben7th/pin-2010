ActiveRecord::Base.transaction do
  feeds = Feed.all
  count = feeds.length
  feeds.each_with_index do |feed,index|
    p "正在运行  #{index+1}/#{count}"
    feed_creator = feed.creator
    unless feed.fav_by?(feed_creator)
      feed_creator.add_fav_feed(feed)
    end
  end
end