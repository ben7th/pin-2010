class PhotoComment <  UserAuthAbstract
  belongs_to :photo
  belongs_to :user
  validates_presence_of :photo
  validates_presence_of :user
  validates_presence_of :content

  module PhotoMethods
    def self.included(base)
      base.has_many :comments,:class_name=>"PhotoComment",
        :order=>"photo_comments.id desc"
    end
  end
end
