class User < UserBase
  include UserMethods
  include Mindmap::UserMethods
  include ImageAttachment::UserMethods
  
  index :email
end