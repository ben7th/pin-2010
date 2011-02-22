require 'RMagick'

class ImgResize
  CACHE_PATH = '/root/image_resize_cache'

  def initialize(image_file_path)
    @image_file_path = image_file_path
  end

  def image_file_path
    @image_file_path
  end

  def file_path
    @image_file_path
  end

  def dir_name
    @dir_name ||= File.dirname(@image_file_path)
  end

  def file_name
    @file_name ||= File.basename(@image_file_path)
  end

  def image
    @image ||= Magick::Image.read(@image_file_path).first
  end

  def width
    self.image.columns
  end

  def height
    self.image.rows
  end

  def cache_path
    @cache_path ||= File.join(CACHE_PATH,self.file_name)
  end

  #获取各种缩图
  def dump_max_of(max_width,max_height)
    min_scale = _get_min_scale(max_width,max_height)
    dump_result = self.image.resize(min_scale)
    _write_file_and_get_path(dump_result)
  end

  private

  def _write_file_and_get_path(dump_result)
    FileUtils.mkdir_p(CACHE_PATH)
    dump_result.write(self.cache_path)
    return self.cache_path
  end

  # 根据输入的允许最大宽度和允许最大高度，计算出合适的缩放百分比
  def _get_min_scale(max_width,max_height)
    w_scale = max_width.to_f / self.width
    h_scale = max_height.to_f / self.height
    return [w_scale , h_scale , 1].min
  end
end

