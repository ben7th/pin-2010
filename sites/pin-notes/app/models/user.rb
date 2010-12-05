class User < UserBase
  include Note::UserMethods
  include Star::UserMethods
end