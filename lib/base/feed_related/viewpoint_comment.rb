class ViewpointComment < UserAuthAbstract
  belongs_to :viewpoint
  belongs_to :user
  validates_presence_of :viewpoint
  validates_presence_of :user
  validates_presence_of :content

  module ViewpointMethods
    def self.included(base)
      base.has_many :comments,:class_name=>"ViewpointComment",:order=>"id desc"
    end

    def create_comment(user,content)
      ViewpointComment.create(:viewpoint=>self,:user=>user,:content=>content)
    end
  end
end
