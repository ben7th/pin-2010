require 'RMagick'
class Photo < UserAuthAbstract
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
  has_attached_file :image,
    :styles => {
    :s500 => "500x500#",
    :r500 => "500x500>",
    :s300 => "300x300#",
    :r300 => "300x300>",
    :s200 => "200x200#",
    :r200 => "200x200>",
    :s100 => "100x100#",
    :r100 => "100x100>",
    :s50 => "50x50#",
    :r50 => "50x50>"
  },
    :path => IMAGE_PATH,
    :url => IMAGE_URL,
    :default_style => :original
  validates_attachment_presence :image

  def image_size(size = :original)
    path = self.image.path(size)
    image = Magick::Image::read(File.new(path)).first
    {:height=>image.rows,:width=>image.columns}
  rescue Exception => ex
    {:height=>0,:width=>0}
  end

  module UserMethods
    def self.included(base)
      base.has_many :photos,:order=>"photos.id desc"
    end
  end

  include FeedPhoto::PhotoMethods
end
