class App < ActiveRecord::Base
  set_readonly(true)
  build_database_connection("pin-app-adapter")

  has_many :installings
  has_many :users,:through=>:installings,:source=>:user

  ATTACHED_FILE_PATH_ROOT = UserBase::LOGO_PATH_ROOT
  ATTACHED_FILE_URL_ROOT = UserBase::LOGO_URL_ROOT

  @logo_path = "#{ATTACHED_FILE_PATH_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  @logo_url = "#{ATTACHED_FILE_URL_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  has_attached_file :logo,:styles => {:s300=>'300x300>',:s64=>"64x64#",:s32=>'32x32#'},
    :path => @logo_path,
    :url => @logo_url,
    :default_url => "/images/logo/default_:class_:style.png",
    :default_style => :s64
end
