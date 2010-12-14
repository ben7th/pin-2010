class User < UserBase
  include Mindmap::UserMethods
  include Cooperation::UserMethods
end