class FeedViewing < UserAuthAbstract
  belongs_to :user
  belongs_to :feed,:counter_cache=>true
  validates_presence_of :user
  validates_presence_of :feed
  validates_uniqueness_of :user_id, :scope => :feed_id

  module FeedMethods
    def self.included(base)
      base.has_many :feed_viewings
    end

    def view_count
      self.feed_viewings.size
    end

    def view_by(user)
      return if user.blank?
      fv = self.feed_viewings.find_by_user_id(user.id)
      return unless fv.blank?
      self.feed_viewings.create(:user=>user)
    end
  end
end
