require 'RMagick'
require 'nokogiri'
require "ap"

class MindmapToImage

  attr_accessor :mindmap
  attr_accessor :map_hash
  attr_accessor :fixed_width,:fixed_height 

  include MindmapToImageParamMethods
  include MindmapToImageHashMethods
  include MindmapToImagePaintMethods

  def initialize(mindmap)
    @mindmap = mindmap
  end


  # 尝试导出导图为图片，返回临时文件地址
  def export(size_param)
    param = size_param.to_s

    if param.include?('x')
      @map_hash = get_nodes_hash(mindmap.struct)
      @fixed_width , @fixed_height = param.split('x').map{|x| x.to_i}
      return write_to_file(export_fixed)
    else
      @zoom = param.to_f # 要在生成hash之前对zoom先赋值
      @map_hash = get_nodes_hash(mindmap.struct)
      return write_to_file(export_zoom)
    end
  end

  def create_thumb
    @map_hash = get_nodes_hash_thumb(mindmap.struct)

    img = export_zoom(false)

    w_500_scale = 500.to_f / img.columns
    h_500_scale = 500.to_f / img.rows
    scale_500 = [w_500_scale, h_500_scale, 1].min

    w_120_scale = 120.to_f / img.columns
    h_120_scale = 120.to_f / img.rows
    scale_120 = [w_120_scale, h_120_scale, 1].min
    
    
    return {
      :s500=>write_to_file(img.resize(scale_500)),
      :s120=>write_to_file(_fit_size(img, 150, 150))
    }
  end
  
  def _fit_size(img, w, h)
    img1 = img.resize_to_fit(w, h)
    x = (img1.columns - w)/2
    y = (img1.rows - h)/2
    
    return img1.extent(w, h, x, y);
  end

  # 尝试导出指定尺寸图片
  def export_fixed
    # 6.25 对于尺寸放大的图片，要做到清晰，目前没有比较好的方法，仍需修改
    @zoom = 1
    img          = export_zoom(false)

    min_scale = _get_min_scale(img)

    img.resize(min_scale)
  end

  # 此处用了ImgResizer的公用代码，将来换成统一的
  def _get_min_scale(img)
    w_scale = @fixed_width.to_f / img.columns
    h_scale = @fixed_height.to_f / img.rows
    return [w_scale , h_scale , 1].min
  end

  # 尝试导出放大缩小的图片
  def export_zoom(with_sign = true)

    image_width = _width_of_image(with_sign)
    image_height = _height_of_image


    gc = get_paint_nodes_gc

    img = Magick::Image.new(image_width, image_height){
      self.background_color = "white"
      self.depth = 8
      self.format = 'PNG'
    }
    gc.draw(img)
    if with_sign
      gc1 = paint_sign(image_width, image_height)
      gc1.draw(img)
    end

    return img
  end

  def _height_of_image
    _height_of_mindmap.round
  end

  def _height_of_mindmap
    map_hash[:max_height] + height_padding
  end

  def _width_of_image(with_sign = true)
    if with_sign
      return [_width_of_mindmap, _width_of_sign].max.round
    end
    return [_width_of_mindmap].max.round
  end

  def _width_of_mindmap
    map_hash[:left_subtree_width] + map_hash[:width] + map_hash[:right_subtree_width] + width_padding + subtree_root_margin*2
  end

  def _width_of_sign
    [get_text_size(sign_title)[:width], 120].max * zoom + width_margin
  end

  def _author_name
    " "
  end

  def write_to_file(img)
    file_path = "/tmp/#{randstr}.png"
    img.write(file_path)
    return file_path
  end
  
end