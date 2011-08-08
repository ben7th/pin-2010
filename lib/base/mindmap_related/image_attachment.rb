require 'RMagick'
class ImageAttachment < Mev6Abstract
  belongs_to :user
  validates_presence_of :user

  if RAILS_ENV == "development"
    IMAGE_PATH = "/web1/2010/:class/:attachment/:id/:style/:basename.:extension"
    IMAGE_URL = "http://dev.mindmap-image-cache.mindpin.com/:class/:attachment/:id/:style/:basename.:extension"
  else
    IMAGE_PATH = "/web/2010/:class/:attachment/:id/:style/:basename.:extension"
    IMAGE_URL = "http://mindmap-image-cache.mindpin.com/:class/:attachment/:id/:style/:basename.:extension"
  end

  # image
  has_attached_file :image, :styles => {:thumb => "90x60>"},
    :path => IMAGE_PATH,
    :url => IMAGE_URL,
    :default_style => :original

  def image_size(size = :original)
    path = self.image.path(size)
    image = Magick::Image::read(File.new(path)).first
    {:height=>image.rows,:width=>image.columns}
  rescue Exception => ex
    {:height=>0,:width=>0}
  end

  module UserMethods
    def self.included(base)
      base.has_many :image_attachments,:order=>"image_attachments.id desc"
    end
  end
end
