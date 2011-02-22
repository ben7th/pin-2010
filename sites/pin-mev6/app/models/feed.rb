class Feed < FeedBase
  set_readonly false

  EDIT_MINDMAP = "edit_mindmap"

  if RAILS_ENV == "development"
    INTERVAL = 5.minutes
  else
    INTERVAL = 8.hours
  end

  self.skip_time_zone_conversion_for_attributes = []

  def self.create_edit_mindmap_feed_when_edit(user,mindmap)
    hrs = HistoryRecord.find(:all,:conditions=>"history_records.mindmap_id = #{mindmap.id} and (history_records.email = '#{user.email}' or history_records.email = '#{EmailActor.get_mindpin_email(user)}')",:order=>"id desc",:limit=>2)
    if hrs.size != 2 || (hrs[0].created_at - hrs[1].created_at) > INTERVAL
      feed = Feed.create(:email=>user.email,:event=>EDIT_MINDMAP,:detail=>{:mindmap_id=>mindmap.id,:mindmap_title=>mindmap.title}.to_json)
      user.news_feed_proxy.update_feed(feed)
    end
  end

  def self.create_edit_mindmap_feed_when_create(user,mindmap)
    feed = Feed.create(:email=>user.email,:event=>EDIT_MINDMAP,:detail=>{:mindmap_id=>mindmap.id,:mindmap_title=>mindmap.title}.to_json)
    user.news_feed_proxy.update_feed(feed)
  end

  module MindmapMethods
    def self.included(base)
      base.after_create :mindmap_edit_feed
    end

    def mindmap_edit_feed
      Feed.create_edit_mindmap_feed_when_create(self.user,self)
      return true
    end
  end

end
