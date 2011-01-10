class User < UserBase
  include Mindmap::UserMethods
  include Cooperation::UserMethods
  include Member::UserMethods

  has_many :contacts
end