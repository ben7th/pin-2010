class User < UserBase
  include Mindmap::UserMethods
  include Cooperation::UserMethods

  has_many :concats
end