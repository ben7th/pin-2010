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

  def get_paint_nodes_gc
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
        gc.fill('black')
        x11 = x1+5
        
        gc.path("M#{x1},#{y1} Q#{(x2+x1)/2},#{y2} #{x2},#{y2} Q#{(x2+x11)/2},#{y2} #{x11},#{y1}")

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
        gc.fill('black')
        x11 = x1 - 5

        gc.path("M#{x1},#{y1} Q#{(x2+x1)/2},#{y2} #{x2},#{y2} Q#{(x2+x11)/2},#{y2} #{x11},#{y1}")

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


    if(node[:inner_img_filepath])
      img_path = node[:inner_img_filepath]
      inner_img = Magick::ImageList.new(img_path)

      gc.composite(x,y-node[:text_height] + 6,80,60,inner_img)

      gc.stroke_width(line_width)
      gc.stroke('transparent')
      gc.fill('black')
      gc.text(x,y+62,title)
    else
      gc.stroke_width(line_width)
      gc.stroke('transparent')
      gc.fill('black')
      gc.text(x,y,title)
    end

    return gc
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

      if(parent[:is_root])
        y = node[:y] = y + v_padding
      end

      unless node[:putright]
        x = node[:x] = parent_x - width - width_margin
      end

      gc = default_gc

      gc.stroke('#999999')
      if node[:bgcolor]
        gc.stroke(node[:bgcolor])
        gc.fill(node[:bgcolor])
      else
        gc.fill('transparent')
      end
      gc.roundrectangle(x-node_inner_x_padding, y-pointsize-node_inner_y_padding,
        x+width+node_inner_x_padding, y-pointsize+height+node_inner_y_padding,
        node_inner_x_padding, node_inner_y_padding)

      if(node[:inner_img_filepath])
        img_path = node[:inner_img_filepath]
        inner_img = Magick::ImageList.new(img_path)

        gc.composite(x,y-node[:text_height] + 6,80,60,inner_img)

        gc.stroke('transparent')
        if node[:textcolor]
          gc.fill node[:textcolor]
        else
          gc.fill('black')
        end
        gc.text(x,y+61,title)
      else
        gc.stroke('transparent')
        if node[:textcolor]
          gc.fill node[:textcolor]
        else
          gc.fill('black')
        end
        gc.text(x,y,title)
      end

      if node[:has_thumb]
        paint_thumb(node)
        return
      end

      if node[:children].length > 0
        # 绘制连接点
        joint_point_x = x + width + border_width*2 +  join_point_offset
        unless node[:putright]
          joint_point_x = x - border_width*2 - join_point_offset
        end

        joint_point_y = y + height/2 - v_padding + join_point_top_offset

        c_top_off = 0
        node[:children].each do |child|
          paint_recursion(node,child,c_top_off)

          # 遍历过程中绘制连接线
          line_x1 = joint_point_x
          line_x2 = joint_point_x - join_point_offset

          # 画短横线
          gc.stroke('#5a5a5a')
          unless node[:putright]
            line_x1 = joint_point_x
            line_x2 = joint_point_x + join_point_offset
            gc.line(line_x1, joint_point_y, line_x2, joint_point_y)
          else
            gc.line(line_x1, joint_point_y, line_x2, joint_point_y)
          end

          bezier_y1 = joint_point_y
          bezier_y2 = y - y_off + node[:cy_off] + c_top_off + child[:y_off] - pointsize + child[:height]/2

          bezier_x1 = line_x1
          bezier_x2 = x + width + width_margin - border_width*2
          unless node[:putright]
            bezier_x2 = x - width_margin + border_width*2
          end

          c_top_off += child[:subtree_height]

          gc.stroke('#5a5a5a')
          gc.fill('transparent')
          gc.bezier(bezier_x1, bezier_y1, (bezier_x1+bezier_x2)/2, bezier_y2, (bezier_x1+bezier_x2)/2, bezier_y2, bezier_x2, bezier_y2)
        end

        gc.stroke('black')
        gc.fill('#999999')
        gc.ellipse(joint_point_x, joint_point_y, joint_point_radius, joint_point_radius, 0, 360)
      end

    end

  def paint_thumb(node)
    gc = default_gc
    
    thumb = node[:children][0]

    width = thumb[:width]
    height = thumb[:height]

    x = node[:x] + node[:width] + 11
    unless node[:putright]
      x = node[:x] - width - 11
    end
    y = node[:y]

    gc.stroke('#444444')
    gc.fill('#444444')

    gc.roundrectangle(x-node_inner_x_padding, y-pointsize-node_inner_y_padding,
      x+width+node_inner_x_padding, y-pointsize+height+node_inner_y_padding,
      5, 5)

    gc.stroke('white')
    gc.fill('white')
    gc.text(x,y,thumb[:title])
  end

  def paint_sign(w,h)
    gc = new_gc
    sign_height = 30 * zoom

    logo_tail_path = "#{File.dirname(__FILE__)}/../images/logo_tail_1.png"
    logo = Magick::ImageList.new(logo_tail_path)

    gc.composite(w-120,h-30,0,0,logo)

#    gc.stroke('black')
#    gc.fill('transparent')
#    gc.rectangle(0,0,w-1,h-1)

    gc.stroke('transparent')
    gc.fill('#C8171F')
    title = "#{mindmap.title} by #{mindmap.user.name}"
    gc.text(10*zoom,20*zoom,title)
  end
end
