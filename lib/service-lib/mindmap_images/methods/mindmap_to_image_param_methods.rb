module MindmapToImageParamMethods
  def zoom
    @zoom || 1
  end

  #################

  def node_padding_x
    3 * zoom
  end

  def node_padding_y
    3 * zoom
  end

  def node_radius
    4 * zoom
  end

  def node_border_width
    1 * zoom
  end

  #################

  # 根节点的padding x方向
  def root_padding_x
    5 * zoom
  end

  # 根节点的padding y方向
  def root_padding_y
    5 * zoom
  end

  # 根节点的圆角半径
  def root_radius
    5 * zoom
  end

  # 根节点的边线宽度
  def root_border_width
    3 * zoom
  end
  
  #######################

  # 同级节点上下间距
  def v_padding
    20 * zoom
  end

  # 字体大小
  def pointsize
    14 * zoom
  end

  # 左边距
  def left_padding
    30 * zoom
  end

  # 顶部边距
  def top_padding
    40 * zoom
  end

  # 底边距？
  def height_padding
    2 * top_padding
  end

  # 右边距？
  def width_padding
    2 * left_padding
  end

  # 左右子树和根节点的间距
  def subtree_root_margin
    30 * zoom
  end

  # 线条宽度
  def line_width
    1 * zoom
  end

  def border_width
    2 * zoom
  end

  def width_margin
    25 * zoom
  end

  def node_join_point_offset_x
    joint_point_radius*2 + node_padding_x + zoom
  end

  def node_join_point_offset_y
    root_join_point_offset_y
  end

  def join_point_top_offset
    1 * zoom
  end

  def joint_point_radius
    3 * zoom
  end

  # 根节点到一级子节点连线的连接点相对于一级子节点的横向偏移量
  def root_join_point_offset_x
    node_padding_x + root_join_point_radius*2 + zoom
  end

  # 根节点到一级子节点连线的连接点相对于一级子节点的纵向偏移量
  def root_join_point_offset_y
    node_padding_y + root_join_point_radius + zoom
  end

  # 根节点到一级子节点连线的连接线宽度
  def root_join_line_width
    5 * zoom
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
