class MindmapComment < Mev6Abstract

  belongs_to :mindmap
  belongs_to :creator,:class_name=>"User",:foreign_key=>"creator_id"

  validates_presence_of :content
  validates_presence_of :creator
  validates_presence_of :mindmap

  module UserMethods
    def self.included(base)
      base.has_many :comments,:class_name=>"MindmapComment",:foreign_key=>"creator_id"
    end

  end

  module MindmapMethods
    def self.included(base)
      base.has_many :comments,:class_name=>"MindmapComment"
    end
  end
  
end
