class User < UserAuthAbstract
  include UserBaseModule
  include UserMethods
  include Mindmap::UserMethods
  include ImageAttachment::UserMethods
end