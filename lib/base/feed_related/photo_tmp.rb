require 'RMagick'
require 'digest/md5'
class PhotoTmp < ActiveRecord::Base
  if RAILS_ENV == "development"
    IMAGE_BASE_PATH = "/web1/2010/photo_tmps/images"
    IMAGE_PATH = "#{IMAGE_BASE_PATH}/:id/:style/:basename.:extension"
    IMAGE_URL = "http://dev.mindmap-image-cache.mindpin.com/:class/:attachment/:id/:style/:basename.:extension"
  else
    IMAGE_BASE_PATH = "/web/2010/photo_tmps/images"
    IMAGE_PATH = "#{IMAGE_BASE_PATH}/:id/:style/:basename.:extension"
    IMAGE_URL = "http://mindmap-image-cache.mindpin.com/:class/:attachment/:id/:style/:basename.:extension"
  end

  validates_attachment_content_type :image,
    :content_type => ['image/gif', 'image/png', 'image/jpeg'],
    :message=>"只能上传图片"
  validates_attachment_presence :image
  # image
  has_attached_file :image,
    :styles => {
      :w660 => "660x>",    #最宽660，原始比例，用于主题show页面
      :w200 => "200x>",    #最宽200，原始比例，用于主题列表（窄）
      :s200 => "200x200#", #200见方，用于相册
      :s66 => "66x66#"     #66见方，用于收集册封面，以及图片上传标识
    },
    :path => IMAGE_PATH,
    :url => IMAGE_URL,
    :default_style => :original

  before_create :set_md5
  def set_md5
    file_path = self.image.queued_for_write[:original].path
    self.md5 = Digest::MD5.hexdigest(File.read(file_path))
  end

  def image_base_path
    File.join(IMAGE_BASE_PATH,self.id.to_s)
  end
end

