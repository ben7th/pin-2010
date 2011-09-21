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
  has_attached_file :image,
    :styles => {
      :w660 => "660x>",    #最宽660，原始比例，用于主题show页面
      :w200 => "200x>",    #最宽200，原始比例，用于主题列表（窄）
      :s200 => "200x200#", #200见方，用于相册
      :s66 => "66x66#"     #66见方，用于收集册封面，以及图片上传标识
    },
    :path => IMAGE_PATH,
    :url => IMAGE_URL,
    :default_style => :original,
    :if=>Proc.new{|photo|!photo.skip_resize_image}

  before_create :set_md5
  def set_md5
    file_path = self.image.queued_for_write[:original].path
    self.md5 = Digest::MD5.hexdigest(File.read(file_path))
  end

  def image_size(size = :original)
    path = self.image.path(size)
    image = Magick::Image::read(File.new(path)).first
    {:height=>image.rows,:width=>image.columns}
  rescue Exception => ex
    {:height=>0,:width=>0}
  end

  def w200_height
    path = self.image.path(:w200)
    image = Magick::Image::read(File.new(path)).first
    image.rows
  rescue Exception => ex
    0
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
