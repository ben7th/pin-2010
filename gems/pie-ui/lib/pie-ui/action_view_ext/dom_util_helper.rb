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