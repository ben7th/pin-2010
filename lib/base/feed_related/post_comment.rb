class PostComment < UserAuthAbstract
  belongs_to :post
  belongs_to :user
  validates_presence_of :post
  validates_presence_of :user
  validates_presence_of :content

  module PostMethods
    def self.included(base)
      base.has_many :comments,:class_name=>"PostComment",:order=>"id asc"
    end

    def create_comment(user,content)
      PostComment.create(:post=>self,:user=>user,:content=>content)
    end
  end
  include Atme::AtableMethods
  include Atme::PostCommentMethods
end
