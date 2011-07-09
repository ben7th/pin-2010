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
    25 * zoom
  end

  def join_point_offset
    5 * zoom
  end

  def join_point_top_offset
    1 * zoom
  end

  def joint_point_radius
    3 * zoom
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
  # 2011年7月4日 因为性能问题，不再采用gc上的方法计算文字宽高
  # 而是自己计算
  # 大概可节约时间 0.5秒 - 1秒
  # 规则：在zoom 1之下：
  # 高度 = (\n 的数量 - 1) * 19
  # 每行宽度 = linestr.split('').map{|x| {1=>8,3=>14}[x.length]}.sum
  # 总宽度 = 最大行宽度
  def get_text_size(text)
    begin
      t = text

      if(t.blank? || t=='')
        t = ' '
      end

      lines = t.split("\n")
      height = lines.length * 19 * zoom
      width = lines.map{|linestr|
        linestr.split('').map{|x| {1=>8,2=>14,3=>14}[x.length]}.sum
      }.max * zoom

      return {:width=>width,:height=>height}
    rescue Exception => ex
      p t
      p t.split("\n")
      p t.split("\n").map{|linestr|
        linestr.split('').map{|x| x.length}
      }
      raise ex
    end

  end

end
