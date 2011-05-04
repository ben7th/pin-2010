FeedMindmap.transaction do
  fms = FeedMindmap.all
  count = fms.length
  fms.each_with_index do |fm,index|
    p "正在处理#{index+1}/#{count}"
    feed = fm.feed

    if feed
      feed.destroy
    end

    fm.destroy
  end

end