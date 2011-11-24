# == Schema Information
# Schema version: 20091223090135
#
# Table name: users
#
#  id                :integer(4)      not null, primary key
#  login             :string(255)     default(""), not null
#  name              :string(255)     default(""), not null
#  hashed_password   :string(255)     default(""), not null
#  salt              :string(255)     default(""), not null
#  email             :string(255)     default(""), not null
#  sign              :string(255)     
#  active_code       :string(255)     
#  activated         :boolean(1)      not null
#  logo_file_name    :string(255)     
#  logo_content_type :string(255)     
#  logo_file_size    :integer(4)      
#  logo_updated_at   :datetime        
#  created_at        :datetime        
#  updated_at        :datetime        
#

# == Schema Information
# Schema version: 20090707030914
#
# Table name: users
#
#  id                :integer(4)      not null, primary key
#  name              :string(255)     default(""), not null
#  hashed_password   :string(255)     default(""), not null
#  salt              :string(255)     default(""), not null
#  email             :string(255)     default(""), not null
#  sign              :string(255)     
#  created_at        :datetime        
#  updated_at        :datetime        
#  active_code       :string(255)     
#  activated         :boolean(1)      not null
#  logo_file_name    :string(255)     
#  logo_content_type :string(255)     
#  logo_file_size    :integer(4)      
#  logo_updated_at   :datetime        
#  role              :string(255)     default("NORMAL")
#

class User < UserBase
  include UserMethods

  has_many :workspaces

  include Activity::UserMethods
  include UserAutoCompeleteCache
  include Mindmap::UserMethods
  include ActivationCode::UserMethods

  include UserBaseEvent
end