class FeedComment < UserAuthAbstract

  belongs_to :feed
  belongs_to :user

  validates_presence_of :content
  validates_presence_of :feed_id
  validates_presence_of :user_id

  index :feed_id,:order=>:desc

  def validate
    if self.content.split(//u).length > 255
      errors.add(:content,"内容长度不能超过 255 个字符")
    end
  end

  module FeedMethods
    def self.included(base)
      base.has_many :feed_comments,:order=>"id asc"
    end

    def comments
      feed_comments
    end

    def comments_count
      feed_comments.length
    end
  end

end
