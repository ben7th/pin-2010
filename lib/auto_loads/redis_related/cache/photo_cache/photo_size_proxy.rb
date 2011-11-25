class PhotoSizeProxy
  def initialize(photo)
    @photo = photo
    @key = "photo_size_#{@photo.id}"
    @redis_cache_hash = RedisCacheHash.new(@key)
  end

  def image_size(style = :original)
    size = image_size_cache(style)
    if size.blank? || size[:width] == 0 || size[:height] == 0
      size = create_cache(style)
    end
    size
  end
  
  def image_size_cache(style = :original)
    size = @redis_cache_hash.get(style.to_s)
    if !size.blank?
      size.to_options!
    end
    size
  end

  def create_cache(style = :original)
    #    {:height=>0,:width=>0}
    size = image_size_db(style)
    @redis_cache_hash.set(style.to_s,size)
    size
  end

  def image_size_db(style = :original)
    path = @photo.image.path(style)
    image = Magick::Image::read(File.new(path)).first
    {:height=>image.rows,:width=>image.columns}
  rescue Exception => ex
    {:height=>0,:width=>0}
  end

  def self.rules
    {
      :class => Photo,
      :after_create => Proc.new{|photo|
        PhotoSizeProxy.new(photo).create_cache
      }
    }
  end

  def self.funcs
    {
      :class => Photo,
      :image_size => Proc.new{|photo,style|
        style = :original if style.blank?
        PhotoSizeProxy.new(photo).image_size(style)
      }
    }
  end
end
