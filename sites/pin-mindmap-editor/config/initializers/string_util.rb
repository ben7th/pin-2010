class String

  # 把 UTF-8 转换成 GBK
  def utf8_to_gbk
    Iconv.conv("gbk","utf-8",self)
  end

  # 把 GBK 转换成  UTF-8
  def gbk_to_utf8
    Iconv.conv("utf-8","gbk",self)
  end

  def to_utf8(charset)
    Iconv.conv("utf-8",charset,self)
  end

  def utf8_to(charset)
    Iconv.conv(charset,"utf-8",self)
  end

  def replace_html_enter_tags_to_text
    str = self.gsub(/<\/?[^>]*>/,  "<br>")
    str.gsub!(/(<\/?br>)+/,"\n")
    str.gsub!(/^(\n)+/,"")
    str.gsub!("&nbsp;","")
    str
  end

end

def randstr(length=8)
  base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  size = base.size
  re = ''<<base[rand(size-10)]
  (length-1).times  do
    re<<base[rand(size)]
  end
  re
end