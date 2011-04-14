class MindmapComment < ActiveRecord::Base

  belongs_to :mindmap
  belongs_to :creator,:class_name=>"User",:foreign_key=>"creator_id"

  validates_presence_of :content
  validates_presence_of :creator
  validates_presence_of :mindmap

  module UserMethods
    def self.included(base)
      base.has_many :comments,:class_name=>"MindmapComment",:foreign_key=>"creator_id"
    end

    def create_comment(mindmap,content,create_feed=false)
      mc = MindmapComment.create(:creator=>self,:mindmap=>mindmap,:content=>content)
      if !mc.new_record? && create_feed
        feed = self.send_say_feed(content)
        FeedMindmap.create(:feed=>feed,:mindmap=>mindmap)
      end
      return !mc.new_record?
    end
  end

  module MindmapMethods
    def self.included(base)
      base.has_many :comments,:class_name=>"MindmapComment"
    end
  end
  
end
