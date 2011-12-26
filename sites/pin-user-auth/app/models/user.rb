class User < UserAuthAbstract
  include UserBaseModule
  include UserMethods
  include ActivationCode::UserMethods
  include UserBaseEvent
end