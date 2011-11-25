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

    def toggle_fav_mindmap(mindmap)
      mfs = MindmapFav.find_all_by_mindmap_id_and_user_id(mindmap.id,self.id)
      if mfs.blank?
        MindmapFav.create(:mindmap=>mindmap,:user=>self)
      else
        mfs.each{|mindmap_fav|mindmap_fav.destroy}
      end
    end
    
  end

  module MindmapMethods
    def self.included(base)
      base.has_many :mindmap_favs
    end

    def faved_by?(user)
      self.fav_users.include?(user)
    end

    def fav_users_db
      mindmap_favs.map do |mindmap_fav|
        mindmap_fav.user
      end
    end
  end

  
end
