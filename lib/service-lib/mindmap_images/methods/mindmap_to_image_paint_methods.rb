module MindmapToImagePaintMethods

  # 默认绘图对象
  def default_gc
    @default_gc ||= new_gc
  end

  def new_gc
    ps = pointsize
    Magick::Draw.new do |opts|
      opts.font = RAILS_ENV == "production" ? "/web/2010/pin-2010/yahei.ttf" : "/web1/pin-2010/yahei.ttf"
      opts.pointsize = ps
    end
  end

  ##########################
  #### 继续重构

  def paint_nodes(img)
    node = map_hash
    gc = default_gc

    oleft = node[:left_subtree_width] + left_padding

    gc.translate(oleft, top_padding)

    gc.fill('black')
    gc.stroke_width(line_width)

    left_c_top_off = node[:left_c_top_off]
    right_c_top_off = node[:right_c_top_off]

    x = node[:x]
    y = node[:y]

    title = node[:title]
    width = node[:width]
    height = node[:height]

    node[:children].each do |child|
      if child[:putright]
        # 右侧
        paint_recursion(node,child,right_c_top_off)

        # 画右侧的一级子节点连接线
        x1 = x + width/2
        y1 = y + height/2 - root_join_point_top_offset

        x2 = child[:x] - root_join_point_offset
        y2 = child[:y] + child[:height]/2 - v_padding

        gc.stroke('#5a5a5a')
        gc.line(x1,y1,x2,y2)
        gc.fill('black')
        gc.ellipse(x2+root_join_point_radius,y2,root_join_point_radius,root_join_point_radius,0,360)

        right_c_top_off += child[:subtree_height]
      else
        # 左侧
        paint_recursion(node,child,left_c_top_off)

        # 画左侧的一级子节点连接线
        x1 = x + width/2
        y1 = y + height/2 - root_join_point_top_offset

        x2 = child[:x] + child[:width] + root_join_point_offset
        y2 = child[:y] + child[:height]/2 - v_padding

        gc.stroke('#5a5a5a')
        gc.line(x1,y1,x2,y2)
        gc.fill('black')
        gc.ellipse(x2-root_join_point_radius,y2,root_join_point_radius,root_join_point_radius,0,360)

        left_c_top_off += child[:subtree_height]
      end
    end

    # 画根结点

    gc.stroke('#77AAFF')
    gc.stroke_width(border_width)
    gc.fill('#E9F0FF')

    gc.roundrectangle(x-root_inner_x_padding,y-pointsize-root_inner_y_padding,
      x+width+root_inner_x_padding,y-pointsize+height+root_inner_y_padding,
      root_inner_x_padding,root_inner_y_padding)

    gc.stroke_width(line_width)
    gc.stroke('transparent')
    gc.fill('black')
    gc.text(x,y,title)

    gc.draw(img)
  end

    def paint_recursion(parent,node,top_off)

      parent_x = parent[:x]
      parent_real_y = parent[:y]-parent[:y_off]
      parent_width = parent[:width]
      parent_cy_off = parent[:cy_off]

      y_off = node[:y_off]

      title = node[:title]
      width = node[:width]
      height = node[:height]

      x = node[:x] = parent_x + parent_width + width_margin
      y = node[:y] = parent_real_y + parent_cy_off + top_off + y_off

      unless node[:putright]
        x = node[:x] = parent_x - width - width_margin
      end

      gc = default_gc

      gc.stroke('transparent')
      gc.fill('black')
      gc.text(x,y,title)

      gc.stroke('#999999')
      gc.fill('transparent')

      gc.roundrectangle(x-node_inner_x_padding, y-pointsize-node_inner_y_padding,
        x+width+node_inner_x_padding, y-pointsize+height+node_inner_y_padding,
        node_inner_x_padding, node_inner_y_padding)

      if node[:children].length > 0
        # 绘制连接点
        r_x = x + width + join_point_offset
        unless node[:putright]
          r_x = x - join_point_offset
        end

        r_y = y + height/2 - v_padding + join_point_top_offset

        c_top_off = 0
        node[:children].each do |child|
          paint_recursion(node,child,c_top_off)

          # 遍历过程中绘制连接线
          x1 = r_x + bezier_x_offset
          x2 = x + width + width_margin - joint_point_radius

          gc.stroke('#5a5a5a')
          unless node[:putright]
            x1 = r_x - bezier_x_offset_right
            x2 = x - width_margin + joint_point_radius
            gc.line(r_x + joint_point_radius*2, r_y, x1, r_y)
          else
            gc.line(r_x - joint_point_radius*2, r_y, x1, r_y)
          end

          y1 = r_y
          y2 = y - y_off + node[:cy_off] + c_top_off + child[:y_off] - pointsize + child[:height]/2

          c_top_off += child[:subtree_height]

          gc.stroke('#5a5a5a')
          gc.fill('transparent')
          gc.bezier(x1,y1,x1,y2,x1,y2,x2,y2)
        end

        gc.stroke('black')
        gc.fill('#999999')
        gc.ellipse(r_x, r_y, joint_point_radius, joint_point_radius, 0, 360)
      end

    end

  def paint_sign(image,w,h)
    gc0 = new_gc
    sign_height = 30 * zoom

    logo_tail_path = "#{File.dirname(__FILE__)}/../images/logo_tail_1.png"
    logo = Magick::ImageList.new(logo_tail_path)

    gc0.composite(w-120,h-30,0,0,logo)

    gc0.stroke('black')
    gc0.fill('transparent')
    gc0.rectangle(0,0,w-1,h-1)

    gc1 = new_gc
    gc1.stroke('transparent')
    gc1.fill('#C8171F')
    gc1.text(10*zoom,20*zoom,mindmap.title)
    gc1.text(get_text_size(mindmap.title).width+sign_height,20*zoom,_author_name)

    gc0.draw(image)
    gc1.draw(image)
  end
end
