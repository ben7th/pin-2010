class FeedDetail < UserAuthAbstract
  HTML_FORMAT = "html"
  belongs_to :feed
  validates_presence_of :feed
  validates_presence_of :content
end


feed_detail_ids = FeedDetail.find_by_sql(%`
    select feed_details.id
    from feed_details
    order by feed_details.id asc
  `).map{|fd|fd.id}

count = feed_detail_ids.length

feed_detail_ids.each_with_index do |id,index|
  p "正在处理 #{index+1}/#{count}"

  fd = FeedDetail.find(id)
  feed = fd.feed
  user = feed.creator
  next if feed.blank?
  next if user.blank?

  post = feed.main_post
  next unless post.blank?

  Post.create(:feed=>feed,:user=>user,
    :memo=>fd.content,:kind=>Post::KIND_MAIN,:format=>fd.format)
end