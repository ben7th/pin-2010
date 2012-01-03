class User < UserAuthAbstract
  include UserBaseModule
  include UserMethods
  include UserCourseItem::UserMethods
  include Profile::UserMethods
end