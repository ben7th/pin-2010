class Feed < FeedBase
  set_readonly false
  EDIT_MINDMAP = "edit_mindmap"

  if RAILS_ENV == "development"
    INTERVAL = 5.minutes
  else
    INTERVAL = 8.hours
  end

  self.skip_time_zone_conversion_for_attributes = []

  def self.create_edit_mindmap_feed_when_create(user,mindmap)
    feed = Feed.create(:email=>user.email,:event=>EDIT_MINDMAP,:detail=>{:mindmap_id=>mindmap.id,:mindmap_title=>mindmap.title}.to_json)
    user.news_feed_proxy.update_feed(feed)
  end

  module MindmapMethods
    def self.included(base)
      base.after_create :mindmap_create_feed
    end
    
    def mindmap_create_feed
      Feed.create_edit_mindmap_feed_when_create(self.user,self)
      return true
    end
  end
end
