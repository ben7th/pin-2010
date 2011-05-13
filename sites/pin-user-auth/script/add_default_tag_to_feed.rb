ActiveRecord::Base.transaction do
  feeds = Feed.all
  count = feeds.length
  feeds.each_with_index do |feed,index|
    p "正在运行  #{index+1}/#{count}"
    feed.add_default_tag_when_no_tag
  end
end