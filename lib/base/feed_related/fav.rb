class Fav < UserAuthAbstract
  belongs_to :feed
  belongs_to :user

  validates_presence_of :feed
  validates_presence_of :user

  def validate_on_create
    favs = Fav.find_all_by_feed_id_and_user_id(self.feed_id,self.user_id)
    errors.add(:base,"重复创建") if !favs.blank?
  end

  module FeedMethods
    def self.included(base)
      base.has_many :favs,:dependent=>:destroy,:order=>"id desc"
      base.has_many :fav_users_db,:through=>:favs,:source=>:user,:order=>"favs.id desc"
    end

    def fav_by?(user)
      self.fav_users.include?(user)
    end
  end

  module UserMethods
    def self.included(base)
      base.has_many :favs,:order=>"id desc"
      base.has_many :fav_feeds_db,:through=>:favs,:source=>:feed,:order=>"favs.id desc"
    end

    def add_fav_feed(feed)
      Fav.find_or_create_by_feed_id_and_user_id(feed.id,self.id)
      return true
    end

    def remove_fav_feed(feed)
      favs = Fav.find_all_by_feed_id_and_user_id(feed.id,self.id)
      favs.each{|fav|fav.destroy}
    end
  end
end
