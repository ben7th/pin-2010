module MindmapToImagePaintMethods

  # 默认绘图对象
  def default_gc
    @default_gc ||= new_gc
  end

  def new_gc
    ps = pointsize
    Magick::Draw.new do |opts|
      opts.font = "/web/2010/pin-2010/yahei.ttf"
      opts.pointsize = ps
    end
  end

  ##########################
  #### 继续重构

  def get_paint_nodes_gc
    node = map_hash
    gc = default_gc

    # 找准中心定位
    center_point_left = node[:left_subtree_width] + left_padding + subtree_root_margin
    center_point_top = top_padding
    gc.translate(center_point_left, center_point_top)

    # 先画子节点
    draw_root_children(gc, node)
    # 后画根结点，否则会被覆盖
    draw_root(gc, node)

    return gc
  end

  def draw_root(gc, node)
    gc.gravity(Magick::NorthWestGravity) # 文字绘制布局NW

    node_x, node_y = node[:x], node[:y]
    node_width, node_height = node[:width], node[:height]
    node_title = node[:title]
    node_title = ' ' if node_title.blank?


    # 画节点边框
    gc.stroke_width(root_border_width)
    gc.stroke(node[:bgcolor] || '#99BFFF')
    gc.fill(node[:bgcolor] || '#E9F0FF')
    gc.roundrectangle(
      node_x - root_padding_x, node_y - root_padding_y,
      node_x + node_width + root_padding_x, node_y + node_height + root_padding_y,
      root_radius, root_radius
    )

    # 画节点图形和文字
    gc.stroke('transparent')
    gc.fill(node[:textcolor]||'black')
    if(node[:inner_img_filepath])
      begin
        img_path = node[:inner_img_filepath]
        inner_img = Magick::ImageList.new(img_path)
        img_width = node[:imgw]
        img_height = node[:imgh]
  
        gc.composite(node_x, node_y, img_width, img_height, inner_img)
        gc.text(node_x, node_y + img_height, node_title)
      rescue
        gc.text(node_x, node_y, node_title)
      end
    else
      gc.text(node_x, node_y, node_title)
    end
  end

  def draw_root_children(gc, node)
    node_x, node_y = node[:x], node[:y]
    node_width, node_height = node[:width], node[:height]
    left_children_top, right_children_top = node[:left_children_top], node[:right_children_top]

    node[:children].each do |child|
      if child[:putright]
        # 右侧
        paint_recursion(node,child,right_children_top)
        right_children_top += child[:subtree_height]

        # 画右侧的一级子节点连接线
        x1 = node_x + node_width/2
        y1 = node_y + node_height/2

        x2 = child[:x] - root_join_point_offset_x
        y2 = child[:y] + child[:height] + root_join_point_offset_y

        x11 = x1 + root_join_line_width

      else
        # 左侧
        paint_recursion(node,child,left_children_top)
        left_children_top += child[:subtree_height]

        # 画左侧的一级子节点连接线
        x1 = node_x + node_width/2
        y1 = node_y + node_height/2

        x2 = child[:x] + child[:width] + root_join_point_offset_x
        y2 = child[:y] + child[:height] + root_join_point_offset_y

        x11 = x1 - root_join_line_width
      end

      gc.stroke_linejoin('round')
      gc.stroke('#222222')
      gc.fill('#222222')
      gc.path("M#{x1},#{y1} Q#{(x2+x1)/2},#{y2} #{x2},#{y2} Q#{(x2+x11)/2},#{y2} #{x11},#{y1}")
      gc.ellipse(x2-root_join_point_radius,y2,root_join_point_radius,root_join_point_radius,0,360)

      line_x1 = x2
      line_y1 = y2
      line_x2 = child[:joint_point_x] - joint_point_radius
      line_y2 = child[:joint_point_y]
      gc.stroke('#5a5a5a')
      gc.line(line_x1, line_y1, line_x2, line_y2)

    end
  end

  def paint_recursion(parent, node, top)
    gc = default_gc

    draw_node(gc, parent, node, top)

    if node[:has_thumb]
      paint_thumb(node)
      return
    end

    draw_node_children(gc, node)
  end

  def draw_node(gc, parent, node, top)
    gc.gravity(Magick::NorthWestGravity) # 文字绘制布局NW

    parent_x = parent[:x]
    parent_real_y = parent[:y] - parent[:y_off]
    parent_width = parent[:width]
    parent_cy_off = parent[:cy_off]

    y_off = node[:y_off]

    node_title = node[:title]
    node_title = ' ' if node_title.blank?
    
    node_width = node[:width]
    node_height = node[:height]

    node_x = parent_x + parent_width + width_margin
    node_y = parent_real_y + parent_cy_off + top + y_off

    unless node[:putright]
      node_x = parent_x - node_width - width_margin
    end

    if(parent[:is_root])
      node_y = node_y + parent[:height]/2
      if(node[:putright])
        node_x = node_x + subtree_root_margin
      else
        node_x = node_x - subtree_root_margin
      end
    end

    node[:x] = node_x
    node[:y] = node_y


    # 画节点边框
    gc.stroke_width(node_border_width)
    gc.stroke(node[:bgcolor] || '#999999')
    if node[:bgcolor] && ['white','#ffffff'].include?(node[:bgcolor].downcase)
      gc.stroke('#999999')
    end
    gc.fill(node[:bgcolor] || 'transparent')
    gc.roundrectangle(
      node_x - node_padding_x, node_y - node_padding_y,
      node_x + node_width + node_padding_x, node_y + node_height + node_padding_y,
      node_radius, node_radius)

    # 画节点图形和文字
    gc.stroke('transparent')
    gc.fill(node[:textcolor]||'black')
    if(node[:inner_img_filepath])
      begin
        img_path = node[:inner_img_filepath]
        inner_img = Magick::ImageList.new(img_path)
        img_width = node[:imgw]
        img_height = node[:imgh]
  
        gc.composite(node_x, node_y, img_width, img_height, inner_img)
        gc.text(node_x, node_y + img_height, node_title)
      rescue
        gc.text(node_x, node_y, node_title)
      end
    else
      gc.text(node_x, node_y, node_title)
    end
  end

  def draw_node_children(gc, node)
    node_x, node_y = node[:x], node[:y]
    node_width, node_height = node[:width], node[:height]

    is_node_putright = node[:putright]

    # 计算连接点位置
    if is_node_putright
      joint_point_x = node_x + node_width + node_join_point_offset_x
    else
      joint_point_x = node_x - node_join_point_offset_x
    end
    node[:joint_point_x] = joint_point_x

    joint_point_y = node_y + node_height + node_join_point_offset_y
    node[:joint_point_y] = joint_point_y

    if node[:children].length > 0


      c_top_off = 0
      node[:children].each do |child|
        paint_recursion(node,child,c_top_off)

        # 遍历过程中绘制连接线

        # 画贝塞尔线

        bezier_x1 = joint_point_x
        bezier_y1 = joint_point_y

        if is_node_putright
          bezier_x2 = child[:x] - root_join_point_offset_x
        else
          bezier_x2 = child[:x] + child[:width] + root_join_point_offset_x
        end
        bezier_y2 = child[:joint_point_y]

        c_top_off += child[:subtree_height]

        gc.stroke_linejoin('round')
        gc.stroke('#5a5a5a')
        gc.fill('transparent')
        gc.bezier(bezier_x1, bezier_y1, (bezier_x1+bezier_x2)/2, bezier_y2, (bezier_x1+bezier_x2)/2, bezier_y2, bezier_x2, bezier_y2)

        # 画下级横线
        line_x1 = bezier_x2
        line_y1 = bezier_y2
        line_x2 = child[:joint_point_x] - joint_point_radius
        line_y2 = child[:joint_point_y] 
        gc.stroke('#5a5a5a')
        gc.line(line_x1, line_y1, line_x2, line_y2)
      end

      gc.stroke('black')
      gc.fill('#999999')
      gc.ellipse(joint_point_x, joint_point_y, joint_point_radius, joint_point_radius, 0, 360)
    end
  end

  # 缩略图中的缩略部分
  def paint_thumb(node)
    gc = default_gc

    thumb = node[:children][0]
    width = thumb[:width]
    height = thumb[:height]


    if node[:putright]
      x = node[:x] + node[:width] + 11*zoom
    else node[:putright]
      x = node[:x] - width - 11*zoom
    end
    y = node[:y] - height + node[:height]

    node[:joint_point_x] = x + width + node_join_point_offset_x
    node[:joint_point_y] = y + height + node_join_point_offset_y

    gc.gravity(Magick::NorthWestGravity)
    gc.stroke('#003266')
    gc.fill('#0067B8')

    gc.roundrectangle(
      x - node_padding_x, y - node_padding_y,
      x + width + node_padding_x, y + height + node_padding_y,
      node_radius, node_radius)

    gc.stroke('white')
    gc.fill('white')
    gc.text(x,y,thumb[:title])
  end



  ######################################################################

  def paint_sign(w,h)
    gc = new_gc

    logo_tail_path = "#{File.dirname(__FILE__)}/../images/tu-logo.png"
    logo = Magick::ImageList.new(logo_tail_path)

    gc.composite(w-168*zoom,h-30*zoom,168*zoom,30*zoom,logo)

    gc.stroke('transparent')
    gc.fill('#C8171F')
    gc.text(10*zoom,20*zoom,sign_title)
  end

  def sign_title
    "#{mindmap.title} by #{mindmap.user.name}"
  end
end
