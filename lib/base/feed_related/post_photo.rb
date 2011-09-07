class PostPhoto < UserAuthAbstract
  belongs_to :post
  belongs_to :photo

  validates_presence_of :post
  validates_presence_of :photo

  module PostMethods
    def self.included(base)
      base.has_many :post_photos
      base.has_many :photos, :through=>:post_photos
    end
  end

  module PhotoMethods
    def self.included(base)
      base.has_many :post_photos
      base.has_many :posts, :through=>:post_photos
    end
  end
end
