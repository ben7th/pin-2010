HtmlDocument.transaction do
  hds = HtmlDocument.all
  hds_count = hds.length
  hds.each_with_index do |hd,index|
    p "正在转换#{index+1}/#{hds_count}"
    feed = hd.feed
    next if feed.blank?
    creator = feed.creator
    next if creator.blank?
    hd.update_attributes!(:creator_id=>creator.id)
  end
end