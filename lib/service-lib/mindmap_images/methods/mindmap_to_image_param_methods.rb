module MindmapToImageParamMethods
  def zoom
    @zoom || 1
  end

  def v_padding
    15 * zoom
  end

  def pointsize
    14 * zoom
  end

  def left_padding
    80 * zoom
  end

  def top_padding
    70 * zoom
  end

  def height_padding
    100 * zoom
  end

  def width_padding
    160 * zoom
  end

  def line_width
    1 * zoom
  end

  def border_width
    2 * zoom
  end

  def width_margin
    40 * zoom
  end

  def join_point_offset
    12 * zoom
  end

  def join_point_top_offset
    1 * zoom
  end

  def joint_point_radius
    4 * zoom
  end

  def root_join_point_offset
    8 * zoom
  end

  def root_join_point_top_offset
    10 * zoom
  end

  def root_join_point_radius
    1.5 * zoom
  end

  def bezier_x_offset
    9 * zoom
  end

  def bezier_x_offset_right
    10 * zoom
  end

  def node_inner_x_padding
    4 * zoom
  end

  def node_inner_y_padding
    2 * zoom
  end

  def root_inner_x_padding
    8 * zoom
  end

  def root_inner_y_padding
    6 * zoom
  end

  # 获取一段文字段落的宽高信息
  def get_text_size(text)
    img ||= Magick::Image.new(1,1,Magick::HatchFill.new('blue','blue'))
    metrics = default_gc.get_multiline_type_metrics(img, text)
    return metrics
  end

end
