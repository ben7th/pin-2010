class FeedChange < UserAuthAbstract
  belongs_to :feed
  belongs_to :user

  module FeedMethods
    def self.included(base)
      base.has_many :feed_changes,:order=>"feed_changes.id asc"
      base.has_many :edited_users,:through=>:feed_changes,:source=>:user,
        :order=>"feed_changes.id asc"
    end

    def last_edited_time
      fc = self.feed_changes.last
      return self.updated_at if fc.blank?
      fc.updated_at
    end

    def last_edited_user
      edited_users.last
    end

    def record_editer(editer)
      FeedChange.create(:feed=>self,:user=>editer)
    end
  end
end
