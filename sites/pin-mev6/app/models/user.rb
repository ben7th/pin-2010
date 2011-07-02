class User < UserBase
  include UserMethods
  include Mindmap::UserMethods
  
  index :email
end