class PostComment < UserAuthAbstract
  belongs_to :post
  belongs_to :user
  validates_presence_of :post
  validates_presence_of :user
  validates_presence_of :content

  module PostMethods
    def self.included(base)
      base.has_many :comments,:class_name=>"PostComment",:order=>"id desc"
    end

    def add_comment(user,content)
      comment = PostComment.new(:post=>self,:user=>user,:content=>content)
      unless comment.save
        raise comment.errors.first[1]
      end
      comment
    end
  end
  include Atme::AtableMethods
  include Atme::PostCommentMethods
end
