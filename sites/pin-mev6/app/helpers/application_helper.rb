# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include MindpinHelperBase
  
  # 评论
  def comment_content(comment)
    str = h comment.content
    str.gsub(MindpinTextFormat::AT_REG) do
      "<a href='/atmes/#{$1}'>@#{$1}</a>"
    end
  end

  def str62keys
    [
      "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
      "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
      "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
    ]
  end

  def int10to62(num10)
    s62 = ''
    r = 0

    num = num10
    while num != 0 do
      r = num % 62
      s62 = str62keys[r] + s62
      num = (num / 62).floor
    end

    return s62
  end

  def int62to10(num62)
    i10 = 0

    arr = num62.split('')
    0.upto arr.length-1 do |i|
      n = arr.length - i - 1
      s = arr[i]
      i10 += str62keys.index(s) * 62**n
    end

    return i10
  end

  # mid转换为URL字符
  # mid 微博mid，如 "201110410216293360"
  # 微博URL字符，如 "wr4mOFqpbO"
  def mid2url(mid_input)
    url = ''

    mid = mid_input.to_s

    (mid.length - 7).step(-7,-7) do |i| #从最后往前以7字节为一组读取mid
      offset1 = i < 0 ? 0 : i;
      offset2 = i + 7;
      int10 = mid[offset1...offset2].to_i
      str = int10to62(int10)
      url = str + url;
    end

    url
  end

end
