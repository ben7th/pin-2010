class User < UserBase
  include Workspace::UserMethods
  include Membership::UserMethods
  include FileEntry::UserMethods
end