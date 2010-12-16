require 'RMagick'

class ImgResize
  # size 是宽和高最大不超的 大小
  # 例如 500
  def self.zoom(src,dec,size)
    img =  Magick::Image.read(src).first
    width = img.columns
    height = img.rows
    percentage = self.resize_percentage(width,height,size)
    thumb = img.resize(percentage)
    FileUtils.mkdir_p(File.dirname(dec))
    thumb.write(dec)
  end

  private
  # width height 原始大小
  # size 压缩后，宽和高的最大值不超过的值
  # 返回 缩放比例
  def self.resize_percentage(width,height,size)
    maxsize = [width,height].max
    return 1 if maxsize < size
    return size.to_f / maxsize
  end
end

