require 'RMagick'
class Photo < UserAuthAbstract
  belongs_to :user
  
  validates_presence_of :user
  validates_attachment_content_type :image,
    :content_type => ['image/gif', 'image/png', 'image/jpeg'],
    :message=>"只能上传图片"
  validates_attachment_presence :image

  # ----
  IMAGE_PATH = "/:class/:attachment/:id/:style/:basename.:extension"
  IMAGE_URL  = "http://storage.aliyun.com/#{OssManager::CONFIG["bucket"]}/:class/:attachment/:id/:style/:basename.:extension"

  # image
  PHOTO_STYLES_HASH = {
    :w500 => '500x>',    #最宽500，原始比例，用于主题show页面，以及手机列表页
    :w250 => '250x>',    #最宽250，原始比例，用于主题列表（一栏）
    :s100 => '100x100#', #100见方，用于草稿的回显，以及手机客户端缩略图，收集册封面，以及图片上传标识
  }

  has_attached_file :image,
    :styles => PHOTO_STYLES_HASH,
    :path => IMAGE_PATH,
    :url => IMAGE_URL,
    :default_style => :original,
    :storage => :oss

  def image_size(style = :original)
    {
      :height => image.height(style),
      :width  => image.width(style)
    }
  end

  def image_height(style = :original)
    image.height(style)
  end

  def image_ratio(style = :original)
    return image.height(style).to_f / image.width(style).to_f
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
end
