ActiveRecord::Base.transaction do
  old_frs = FeedRevision.all
  old_frs_count = old_frs.length

  old_frs.each_with_index do |fr,index|
    p "destroy old feed_revisions #{index+1}/#{old_frs_count}"
    fr.destroy
  end
end


ActiveRecord::Base.transaction do
  feeds = Feed.normal
  feeds_count = feeds.length

  feeds.each_with_index do |feed,index|
    p "正在创建feed_revisions #{index+1}/#{feeds_count}"

    fr = FeedRevision.new(:user=>feed.creator,:feed=>feed,
      :title=>feed.content,:detail=>feed.detail_content,:tag_ids_json=>feed.tag_ids.to_json
    )
    fr.created_at = feed.created_at
    fr.updated_at = feed.created_at
    fr.save_without_timestamping
  end
end
