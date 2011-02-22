class User < UserBase
  include Mindmap::UserMethods

  index :email
end