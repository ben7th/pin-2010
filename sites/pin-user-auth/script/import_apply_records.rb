feeds = Collection.find_by_title("激活码申请").feeds
feeds = feeds.sort{|a,b|a.id<=>b.id}
count = feeds.count
feeds.each_with_index do |feed,index|
  p "正在处理 #{index+1}/#{count}"
  
  ApplyRecord.create_from_feed(feed)
end