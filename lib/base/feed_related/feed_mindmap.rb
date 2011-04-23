class FeedMindmap < UserAuthAbstract
  belongs_to :feed
  belongs_to :mindmap

  validates_presence_of :feed_id
  validates_presence_of :mindmap_id

  def validate_on_create
    feed_mindmaps = FeedMindmap.find_all_by_feed_id_and_mindmap_id(self.feed_id,self.mindmap_id)
    errors.add(:base,"重复创建") if !feed_mindmaps.blank?
  end

  module FeedMethods
    def self.included(base)
      base.has_many :feed_mindmaps, :dependent=>:destroy, :foreign_key=>"feed_id"
    end
    
    def mindmaps_db
      feed_mindmaps.map do |feed_mindmap|
        Mindmap.find_by_id(feed_mindmap.mindmap_id)
      end
    end

  end

  module MindmapMethods
    def self.included(base)
      base.has_many :feed_mindmaps, :dependent=>:destroy, :foreign_key=>"mindmap_id"
    end

    def feeds_db
      feed_mindmaps.map do |feed_mindmap|
        Feed.find_by_id(feed_mindmap.feed_id)
      end
    end

  end

end
