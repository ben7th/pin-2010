class MindmapFav < Mev6Abstract

  belongs_to :user
  belongs_to :mindmap

  validates_presence_of :user
  validates_presence_of :mindmap
  validates_uniqueness_of :user_id, :scope => :mindmap_id

  module UserMethods
    def self.included(base)
      base.has_many :mindmap_favs
      base.has_many :fav_mindmaps_db,:through=>:mindmap_favs,:source=>:mindmap,:order=>"mindmap_favs.id desc"
    end
    
    def add_fav_mindmap(mindmap)
      MindmapFav.find_or_create_by_mindmap_id_and_user_id(mindmap.id,self.id)
      return true
    end

    def remove_fav_mindmap(mindmap)
      mindmap_favs = MindmapFav.find_all_by_mindmap_id_and_user_id(mindmap.id,self.id)
      mindmap_favs.each{|mindmap_fav|mindmap_fav.destroy}
    end
  end

  module MindmapMethods
    def self.included(base)
      base.has_many :mindmap_favs
    end

    def fav_by?(user)
      self.fav_users.include?(user)
    end

    def fav_users_db
      mindmap_favs.map do |mindmap_fav|
        mindmap_fav.user
      end
    end
  end

  
end
