class User < UserBase
  include Share::UserMethods
  include Feeling::UserMethods
  include Contacting::HostMethods
  include Entry::UserMethods

  # 在线状态记录
  has_one :online_record,:dependent => :destroy
end
