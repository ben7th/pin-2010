class User < UserBase
  include Mindmap::UserMethods
  include Cooperation::UserMethods
  include Member::UserMethods

  index :email
  has_many :contacts
end