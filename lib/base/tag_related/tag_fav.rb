class TagFav < UserAuthAbstract
  belongs_to :tag
  belongs_to :user
  validates_presence_of :tag
  validates_presence_of :user
  validates_uniqueness_of :tag_id, :scope => :user_id

  module UserMethods
    def self.included(base)
      base.has_many :tag_favs
      base.has_many :fav_tags,:through=>:tag_favs,:source=>:tag
    end

    def fav_tag_feeds_db
      feeds = self.fav_tags.map do |tag|
        tag.feeds
      end.flatten.uniq
      feeds.sort{|x,y|y.id<=>x.id}
    end
    
    def do_fav_tag(tag)
      TagFav.find_or_create_by_tag_id_and_user_id(tag.id,self.id)
    end

    def do_unfav_tag(tag)
      tag_fav = tag.tag_favs.find_by_user_id(self.id)
      tag_fav.destroy unless tag_fav.blank?
    end
  end

  module TagMethods
    def self.included(base)
      base.has_many :tag_favs
      base.has_many :fav_users,:through=>:tag_favs,:source=>:user
    end

    def fav_by?(user)
      self.fav_users.include?(user)
    end
    
  end
end
