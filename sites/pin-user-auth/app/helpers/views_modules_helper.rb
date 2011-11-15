module ViewsModulesHelper

  def morender(kind,name,params={})
    begin
      render "views_modules/#{kind.pluralize}/#{name}",params
    rescue Exception => ex
      "<div class='render-error'>错误：#{ex}</div>"
    end
  end

  def prender(kind,name,params={})
    begin
      render "#{kind.pluralize}/parts/#{name}",params
    rescue Exception => ex
      "<div class='render-error'>错误：#{ex}</div>"
    end
  end

  def render_with_error_msg(err_message, path, params={})
    begin
      render path, params
    rescue Exception => ex
      return "<div class='render-error'>错误：#{ex}</div>"          if RAILS_ENV=='development'
      return "<div class='render-error'>错误：#{err_message}</div>" if RAILS_ENV=='production'
    end
  end

  # 计算宽度为415的大图的尺寸以及容器div尺寸，用在列表里
  def grid_photo_large_sizes(photo, style, max_width, max_height, fixed=false)
    size = photo.image_size(style)
    width, height = size[:width], size[:height]

    if width >= max_width
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

end
