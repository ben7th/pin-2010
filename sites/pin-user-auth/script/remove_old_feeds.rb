ActiveRecord::Base.transaction do
  t = Time.local(2011,5,10,8,0,0)
  #5月10号前的
  feeds = Feed.find(:all,:conditions=>"created_at < '#{t.utc.strftime("%Y-%m-%d %H:%M:%S")}'")
  #没有关键词的
  feeds = feeds.select{|feed|feed.tag_names == ["没有关键词"]}
  #没有正文的
  feeds = feeds.select{|feed|feed.feed_detail.blank?}
  #没有观点的
  feeds = feeds.select{|feed|feed.viewpoints.blank?}

  feeds_count = feeds.count
  feeds.each_with_index do |feed,index|
    p "正在处理 #{index+1}/#{feeds_count}"

    begin
      feed.destroy
    rescue Exception => ex
    end

  end
end
