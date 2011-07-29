feed_ids = Feed.find_by_sql(%`
    select feeds.id from feeds order by feeds.id asc
  `).map{|f|f.id}
count = feed_ids.length

begin
  feed_ids.each_with_index do |id,index|
    p "正在处理 feed_#{id}  #{index+1}/#{count}"

    feed = Feed.find_by_id(id)
    next if feed.blank?

    SendScope.create!(:param=>SendScope::ALL_PUBLIC,:feed=>feed)
  end
rescue Exception => ex
  puts ex.backtrace.join("\n")
  puts ex.message
  raise ex
end