class FileEntry < ActiveRecord::Base
  belongs_to :workspace
  belongs_to :user

  @file_path = "#{UserBase::LOGO_PATH_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  @file_url = "#{UserBase::LOGO_PATH_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  has_attached_file :content,
    :path => @file_path,
    :url => @file_url

  validates_attachment_presence :content,:message=>'请上传文件'
  

  module WorkspceMethods
    def self.included(base)
      base.has_many :file_entries
    end
  end

  module UserMethods
    def self.included(base)
      base.has_many :file_entries
    end
  end
end
