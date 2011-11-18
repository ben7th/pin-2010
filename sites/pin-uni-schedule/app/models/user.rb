class User < UserBase
  include UserMethods
  index :email

  include UserCourseItem::UserMethods
  include Profile::UserMethods
end