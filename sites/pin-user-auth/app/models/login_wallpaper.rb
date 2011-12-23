class LoginWallpaper < ActiveRecord::Base
  validates_attachment_content_type :image,
    :content_type => ['image/gif', 'image/png', 'image/jpeg'],
    :message=>"只能上传图片"
  validates_attachment_presence :image

  IMAGE_PATH = "/:class/:attachment/:id/:style/:basename.:extension"
  IMAGE_URL  = "http://storage.aliyun.com/#{OssManager::CONFIG["bucket"]}/:class/:attachment/:id/:style/:basename.:extension"

  has_attached_file :image,
    :styles => {
    :s250  => '250x250#',
    :s500 => '500x500#',
  },
    :path => IMAGE_PATH,
    :url => IMAGE_URL,
    :default_style => :original,
    :storage => :oss
end
