class TodoMemoComment < UserAuthAbstract
  belongs_to :todo_user
  belongs_to :user
  validates_presence_of :todo_user
  validates_presence_of :user
  validates_presence_of :content

  module TodoUserMethods
    def self.included(base)
      base.has_many :comments,:class_name=>"TodoMemoComment",:order=>"id desc"
    end

    def create_comment(user,content)
      TodoMemoComment.create(:todo_user=>self,:user=>user,:content=>content)
    end
  end
end
