class WeiboStatus < UserAuthAbstract  
  STR62KEYS = [
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", 
    "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", 
    "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
  ]

  def mash
    obj = ActiveSupport::JSON.decode(self.json)
    m = Hashie::Mash.new(obj)
    def m.hash
      inspect.hash
    end
    return m
  end

  class << self
    def get_by_chars(chars)
      mid = chars2mid(chars)
      get(mid)
    end

    def get(mid)
      weibo_status = WeiboStatus.find_by_mid(mid)
      if weibo_status.blank?
        weibo = public_weibo
        m = weibo.status(mid)
        weibo_status = WeiboStatus.create(:mid=>m.mid,:uname=>m.user.name,:uid=>m.user.id,:json=>m.to_json)
      end
      weibo_status
    end

    # 根据传入的user获取一个微博连接对象，以便执行API方法
    def public_weibo(user = nil)
      if !user.blank? && user.has_binded_tsina?
        return user.tsina_weibo
      else
        return User.find(1016287).tsina_weibo if RAILS_ENV=='development' # 1016287 漫品 ben7th6@sina.com
        return User.find(1009).tsina_weibo if RAILS_ENV=='production' # 1009 大灰狼果糖 ben7th@126.com
      end
    end
    
    # -----------------------------

    # mid转换为URL字符
    # mid 微博mid，如 "201110410216293360"
    # 微博URL字符，如 "wr4mOFqpbO"
    def mid2chars(mid_input)
      chars = ''

      mid = mid_input.to_s

      (mid.length - 7).step(-7,-7) do |i| #从最后往前以7字节为一组读取mid
        offset1 = i < 0 ? 0 : i;
        offset2 = i + 7;
        int10 = mid[offset1...offset2].to_i
        str = int10to62(int10)
        chars = "#{str}#{chars}"
      end

      chars
    end

    # mid转换为URL字符
    # 微博URL字符，如 "wr4mOFqpbO"
    # mid 微博mid，如 "201110410216293360"
    def chars2mid(chars_input)
      mid = ''

      (chars_input.length - 4).step(-4,-4) do |i|
        offset1 = i < 0 ? 0 : i;
        offset2 = i + 4;
        int62 = chars_input[offset1...offset2]
        str = int62to10(int62)
        mid = "#{str}#{mid}"
      end
      
      mid.to_i
    end

    # 10进制转62进制
    def int10to62(num10)
      s62 = ''
      r = 0

      num = num10
      while num != 0 do
        r = num % 62
        s62 = STR62KEYS[r] + s62
        num = (num / 62).floor
      end

      return s62
    end

    # 62进制转10进制
    def int62to10(num62)
      i10 = 0

      arr = num62.split('')
      0.upto arr.length-1 do |i|
        n = arr.length - i - 1
        s = arr[i]
        i10 += STR62KEYS.index(s) * 62**n
      end

      return i10
    end
  end

end
