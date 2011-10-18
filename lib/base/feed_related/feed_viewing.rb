class FeedViewing < UserAuthAbstract
  belongs_to :user
  belongs_to :feed
  validates_presence_of :user
  validates_presence_of :feed
  validates_uniqueness_of :user_id, :scope => :feed_id

  after_create :update_feed_view_count
  def update_feed_view_count
    feed = self.feed
    feed.feed_viewings_count = feed.feed_viewings.count
    feed.save_without_timestamping
    return true
  end


  module FeedMethods
    def self.included(base)
      base.has_many :feed_viewings
    end

    def save_viewed_by(user)
      return if user.blank?
      fv = self.feed_viewings.find_by_user_id(user.id)
      return unless fv.blank?
      self.feed_viewings.create(:user=>user)
    end
  end
end
