class FeedFormat

  def initialize(feed)
    @feed = feed
    @title = feed.title || ''
    @detail = feed.detail || ''
    
    @widget_hash = {}

    @photos = feed.photos
    @photo_used = false

    @transed_detail = _detail # 顺序不可改
  end

  def photo_used; @photo_used; end

  # --------- 10月31日之后的新api

  #  1 列表状态（brief状态）。用于在列表中进行文本概览。
  #  规则：
  #  只显示纯文本。最终显示文本中不应该包含任何非预期且未escape的html标记。
  #  截取300个字符进行显示。应该在第一次html转义前截取，否则可能会导致<br/>等标记被截半。
  #  连续回车换行，如果>2次，全部截短为2次。
  #
  #  生成顺序
  #  str = 原文持久存储字符串
  #  str0 = 换行符标准化(str)
  #  str1 = 2次以上/n减为1次/n(str1)
  #  str2 = 截取300字（str1）
  #  str3 = html_escape(str2)
  #  str4 = 转换\n为<br/>(str3)
  #  str5 = 转换空格为nbsp(str4)
  #  return str5

  def detail_brief(length = 300)
    str0 = typical_return(@detail) # 回车换行标准化

    str1 = reduce_return(str0)
    str2 = truncate_u(str1, length, '…')
    str3 = _escape_html(str2)
    str4 = trans_return_to_br(str3)
    str5 = trans_space_to_nbsp(str4)
    
    return str5
  end

  def short_detail_brief
    detail_brief(150)
  end


  #  2 显示状态（非brief状态）。用于在show页面等进行显示。
  #  规则：
  #  显示经过mindpin_format转义后的文本，可能包含内嵌图片，程序段，视频，其他主题引用等。不断丰富。
  #
  #  生成顺序
  #  str = 原文持久存储字符串
  #  str1 = html_escape(str)
  #  str2 = 转换\n为<br/>(str1)
  #  str3 = 转换空格为nbsp(str2)
  #  str4 = 转换各种格式组件(str3)
  #  return str4

  def detail
    @transed_detail
  end

  def _detail
    str0 = typical_return(@detail) # 回车换行标准化

    str1 = trans_code(str0)
    str2 = trans_images(str1)

    str3 = _escape_html(str2)
    str4 = trans_return_to_br(str3)
    str5 = trans_space_to_nbsp(str4)

    str6 = pack_widgets(str5)

    return str6
  rescue Exception=>ex
    return "文本解析错误 #{ex}"
  end

  def title
    str1 = _escape_html(@title)
    return str1
  end
  
  def title_brief(length = 32)
    str1 = truncate_u(title, length, '…')
    return str1
  end

  private
    # 去掉所有的\r，使得换行符标准化
    def typical_return(str)
      str.gsub(/\r/,"")
    end

    # 最大限度缩减正文内的换行符数量
    # 去掉开头和结尾的换行
    # 去掉连续的一个以上的换行
    # 去掉多个换行中间夹杂空白字符
    def reduce_return(str)
      str1 =  str.gsub(/^\n+/, "") # 去掉开头的连续\n
      str2 = str1.gsub(/\n(\s|\n)*$/, "") # 去掉末尾的连续\n和\s
      str3 = str2.gsub(/\n(\s|\n)*\n/, "\n") # 去掉中间的连续\n
      return str3
    end

    def trans_return_to_br(str)
      return str.gsub(/\n/,'<br/>')
    end

    def trans_space_to_nbsp(str)
      return str.gsub(/\s/,'&nbsp;')
    end

    # 转换正文中的程序段
    def trans_code(str)
      str.gsub /\[code (.+)\]((\w|\W)+)\[\/code]/ do |s|
        lang = $1
        lines = $2

        # 去掉前面和后面的换行符
        lines.gsub! /^\n*/,''
        lines.gsub! /\n*$/,''

        head_str = "<div class='feed-format-code-head'>#{lang} code</div>"
        # widget_str = CodeRay.scan(lines, lang).div(:css => :class)
        div = Nokogiri::XML.fragment CodeRay.scan(lines, lang).div(:css => :class)
        div.at_css('div.code')['class']="code #{lang}"
        # div.at_css('div.code').before head_str
        widget_str = div.to_xml

        push_in_hash("#{head_str}#{widget_str}")
      end
    end

    # 转换正文中的图片引用
    def trans_images(str)
      str.gsub /\[图片([0-9])+\](\n)*/ do |s|
        index = $1.to_i - 1
        photo = @photos[index]
        if !photo.blank?
          @photo_used = true
          push_in_hash "<div class='feed-format-img'><img src='#{photo.image.url(:w500)}'/></div>"
        else
          s
        end
      end
    end

    # 将转换好的组件代码先存放在一个hash里
    def push_in_hash(widget_str)
      key = "[r=#{randstr}]"
      @widget_hash[key] = widget_str

      return key
    end

    # 最后，把所有组件代码从hash里替换回来
    def pack_widgets(str)
      re = str
      @widget_hash.each do |key, value|
        re.gsub! key, value
      end
      re
    end

    # 自定义的html转义方法，不对 & 和 " 进行转义
    def _escape_html(str)
      str.gsub(/>/, "&gt;").gsub(/</, "&lt;")
    end
end
