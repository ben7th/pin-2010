module PieUi
  module DomUtilHelper

    def is_ie?
      /MSIE 6/.match(request.user_agent)
    end

    def is_ff?
      /Firefox/.match(request.user_agent)
    end

    # 清除一段文本中的html标签
    def clear_html(text,replacement='')
      (text||'').gsub(/<[^>]*>/){|html| replacement}
    end

    # utf8下将中文当成两个字符处理的自定义的truncate方法
    # 取自javaeye上庄表伟和quake wang的方法
    # 由于quake wang的方法在需要截取的字符数大于30时有较严重的效率问题，导致卡死进程
    # 因此需要截取长度大于30时使用庄表伟的方法
    def truncate_u(text, length = 30, truncate_string = "...")
      if length >= 30
        l=0
        char_array=text.unpack("U*")
        char_array.each_with_index do |c,i|
          l = l+ (c<127 ? 0.5 : 1)
          if l>=length
            return char_array[0..i].pack("U*")+(i<char_array.length-1 ? truncate_string : "")
          end
        end
        return text
      else
        if r = Regexp.new("(?:(?:[^\xe0-\xef\x80-\xbf]{1,2})|(?:[\xe0-\xef][\x80-\xbf][\x80-\xbf])){#{length}}", true, 'n').match(text)
          return r[0].length < text.length ? r[0] + truncate_string : r[0]
        else
          return text
        end
      end
    end

    def truncate_filename(filename,length = 4)
      # 把文件名从 . 切开成数组，并把 . 保留
      # 例如 "1.txt"=>["1",".","txt"]
      old_names = filename.split(/(\.)/)
      if old_names[-2] == '.'
        # 有后缀名
        base_name = old_names[0...-2]*""
        suffix_name = old_names[-2..-1]*""
        return "#{truncate_u(base_name,length)}#{suffix_name}"
      else
        # 没有后缀名
        return "#{truncate_u(old_names*"",length)}"
      end
    end

    # 摘要
    def brief(text)
      "　　"<<h(truncate_u(text,28))
    end

    # 对纯文本字符串进行格式化，增加中文段首缩进，以便于阅读
    def group_content_format(content,indent=0)
      indent_str = '　'*indent
      simple_format_str = simple_format(h(content))
      return simple_format_str.
              gsub('<p>', "#{indent_str}<p>").
              gsub('<br />',"#{indent_str}<br/>").
              gsub(' ','&nbsp;')
    end

    def ct(content)
      group_content_format(content)
    end

    #i 原始数 n 要保留的小数位数，flag=1 四舍五入 flag=0 不四舍五入
    def _4s5r(i,n=2,flag=1)
      return 0 if i.blank?
      i = i.to_f
      y = 1
      n.times do |x|
        y = y*10
      end
      if flag==1
        (i*y).round/(y*1.0)
      else
        (i*y).floor/(y*1.0)
      end
    end

    def flash_info
      re = []
      [:notice,:error,:success].each do |kind|
        msg = flash[kind]
        re << "<div class='flash-#{kind}'><span>#{msg}</span></div>" if !msg.blank?
      end
      re*''
    end

  end
end