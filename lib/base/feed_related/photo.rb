require 'RMagick'
require 'digest/md5'
class Photo < UserAuthAbstract
  belongs_to :user
  validates_presence_of :user

  if RAILS_ENV == "development"
    IMAGE_BASE_PATH = "/web1/2010/photos/images"
    IMAGE_PATH = "#{IMAGE_BASE_PATH}/:id/:style/:basename.:extension"
    IMAGE_URL = "http://dev.mindmap-image-cache.mindpin.com/:class/:attachment/:id/:style/:basename.:extension"
  else
    IMAGE_BASE_PATH = "/web/2010/photos/images"
    IMAGE_PATH = "#{IMAGE_BASE_PATH}/:id/:style/:basename.:extension"
    IMAGE_URL = "http://mindmap-image-cache.mindpin.com/:class/:attachment/:id/:style/:basename.:extension"
  end

  validates_attachment_content_type :image,
    :content_type => ['image/gif', 'image/png', 'image/jpeg'],
    :message=>"只能上传图片",:if=>Proc.new{|photo|!photo.skip_resize_image}
  validates_attachment_presence :image,:if=>Proc.new{|photo|!photo.skip_resize_image}


  # image
  PHOTO_STYLES_HASH = {
    :w660 => '660x>',    #最宽660，原始比例，用于主题show页面，以及手机列表页
    :w210 => '210x>',    #最宽210，原始比例，用于主题列表（一栏）
    :s100 => '100x100#', #100见方，目前暂时用于草稿的回显，以及手机客户端缩略图
    :s66 => '66x66#'     #66见方，用于收集册封面，以及图片上传标识
  }

  has_attached_file :image,
    :styles => PHOTO_STYLES_HASH,
    :path => IMAGE_PATH,
    :url => IMAGE_URL,
    :default_style => :original,
    :if=>Proc.new{|photo|!photo.skip_resize_image}

  before_create :set_md5
  def set_md5
    file_path = self.image.queued_for_write[:original].path
    self.md5 = Digest::MD5.hexdigest(File.read(file_path))
  end

  def image_height(style = :original)
    image_size(style)[:height]
  end

  def image_ratio(style = :original)
    return image_size(style)[:height].to_f / image_size(style)[:width].to_f
  end

  def image_base_path
    File.join(IMAGE_BASE_PATH,self.id.to_s)
  end

  def skip_resize_image
    @skip_resize_image
  end

  def skip_resize_image=(skip_resize_image)
    @skip_resize_image=skip_resize_image
  end

  module UserMethods
    def self.included(base)
      base.has_many :photos,:order=>"photos.id desc"
    end

    def create_photo_or_find_by_file_md5(file)
      self.photos.create(:image=>file)
#      md5 = Digest::MD5.hexdigest(File.read(file_path))
#
#      photo = self.photos.find_by_md5(md5)
#      if photo.blank?
#        photo = self.photos.create(:image=>File.new(file_path))
#      end
#      photo
    end
  end

  include PostPhoto::PhotoMethods
  include PhotoComment::PhotoMethods
end
