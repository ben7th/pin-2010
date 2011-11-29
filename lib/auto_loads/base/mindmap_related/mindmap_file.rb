class MindmapFile < Mev6Abstract
  belongs_to :mindmap

  @file_path = "/:class/:attachment/:id/:style/:basename.:extension"
  @file_url  = "http://storage.aliyun.com/#{OssManager::CONFIG["bucket"]}/:class/:attachment/:id/:style/:basename.:extension"
  has_attached_file :file,
    :storage => :oss,
    :path => @file_path,
    :url  => @file_url
end
