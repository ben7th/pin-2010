class FeedComment < ActiveRecord::Base

  belongs_to :feed
  belongs_to :user

  validates_presence_of :content
  validates_presence_of :feed_id
  validates_presence_of :user_id

  module FeedMethods
    def self.included(base)
      base.has_many :feed_comments,:order=>"id desc"
    end

    def comments_count
      feed_comments.size
    end
  end
end
