module ViewsModulesHelper

  def morender(kind,name,params={})
    begin
      render "views_modules/#{kind.pluralize}/#{name}",params
    rescue Exception => ex
      "<div class='render-error'>错误：#{ex}</div>"
    end
  end

  def prender(kind,name,params={})
    render "#{kind.pluralize}/parts/#{name}",params
  end

  # 计算宽度为415的大图的尺寸以及容器div尺寸，用在列表里
  def grid_photo_large_sizes(photo, style, max_width, max_height, fixed=false)
    size = photo.image_size(style)
    width, height = size[:width], size[:height]

    if width > max_width
      height = height * max_width / width
      width = max_width
    end

    if !fixed
      box_height = [max_height, height].min
    else
      box_height = max_height
    end

    margin_top = (box_height - height)/2

    return {
      :src        => photo.image.url(style),
      :box_height => box_height,
      :width      => width,
      :height     => height,
      :margin_top => margin_top
    }
  end

  # 计算某个正方形容器区域内图片的尺寸和缩进，用在列表里
  def grid_photo_square_sizes(photo, style, max_side)
    size = photo.image_size(style)
    width, height = size[:width], size[:height]

    if height >= width
      if width > max_side
        height = height * max_side / width
        width = max_side
      end
    else
      if height > max_side
        width = width * max_side / height
        height = max_side
      end
    end

    margin_top = (max_side - height)/2
    margin_left = (max_side - width)/2

    return {
      :src        => photo.image.url(style),
      :box_height => max_side,
      :width      => width,
      :height     => height,
      :margin_top => margin_top,
      :margin_left=> margin_left
    }
  end

end
