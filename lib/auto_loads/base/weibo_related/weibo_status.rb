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
    # 根据 url 找到 微博上 对应的 short_url 并找到对应的信息
    def find_weibo_info_by_long_url(long_url)
      tsina_weibo = WeiboStatus.public_weibo
      url_short = tsina_weibo.send(:perform_get,'/short_url/shorten.json',:query=>{:url_long=>long_url}).first.url_short
      tsina_weibo.send(:perform_get,'/short_url/batch_info.json',:query=>{:url_short=>url_short}).first
    end

    def find_weibo_info_by_short_url(short_url)
      tsina_weibo = WeiboStatus.public_weibo
      tsina_weibo.send(:perform_get,'/short_url/batch_info.json',:query=>{:url_short=>short_url}).first
    end

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

  class Bundle
    # 原始内容
    # [ status, status]
    #  status {
    #    :id=>xx,
    #    :retweeted_status=>status
    # }
    # 最终转换成
    # [new_status,new_status]
    # new_status{
    #  :status=>status,
    #  :retweeted_status=>status,
    #  statuses=>[status,status]
    # }
    def self.bundle_statuses(statuses)
      # 第一步转换成 middle_hash {
      # :status_id=>{new_status}
      # }
      middle_hash = {}
      statuses.each do |status|
        rs = status.retweeted_status
        if rs.blank?
          middle_hash[status.id] ||= Bundle.new(status.id)
          middle_hash[status.id].add_status(status)
        else
          middle_hash[rs.id] ||= Bundle.new(rs.id)
          middle_hash[rs.id].add_status(status)
        end
      end
      # 第二部把  middle_hash 转换成 数组 并 按照 count 排序
      middle_hash.values.sort{|a,b|b.count<=>a.count}
    end

    def initialize(status_id)
      @status_id = status_id.to_i
      @hash = {:id=>@status_id}
    end

    def status
      @hash[:status]
    end

    def statuses
      @hash[:statuses]
    end

    def retweeted_status
      @hash[:retweeted_status]
    end

    def count
      @hash[:count]
    end

    def add_status(status)
      rs = status.retweeted_status
      if rs.blank?
        raise "错误的操作" if status.id.to_i != @status_id
        @hash[:status=>status]
      else
        raise "错误的操作" if rs.id.to_i != @status_id
        @hash[:retweeted_status] = rs if @hash[:retweeted_status].blank?
        @hash[:statuses] = (@hash[:statuses]||[])+[status]
      end
      @hash[:count] = (@hash[:count] || 0) + 1
    end
  end

  class Stat
    #  返回一些统计值
    #:original_count 原创数目
    #:repost_count 转发数目
    #:no_reply_count 没有被评论，被转发的数目
    #:commented_count 被评论过的数目
    #:be_reposted_count 被转发过的数目
    #
    #:most_posted_users => [
    #    {:user=>weibo_user, :count=>..., :statuses=>[...]}
    #]
    # 第一步 most_posted_users_hash = {
    #   :user_id=>{:user=>weibo_user, :count=>..., :statuses=>[...]}
    # }
    def self.analyze(statuses)
      user = User.find(271).tsina_weibo.friends(:count=>1)[0]
      return {
        :original_count=>5,
        :repost_count=>15,
        :no_reply_count=>2,
        :commented_count=>15,
        :be_reposted_count=>18,
        :most_posted_users => [
          {:user=>user, :count=>20, :statuses=>statuses}
        ]
      }
#      original_count = 0
#      repost_count = 0
#      no_reply_count = 0
#      commented_count = 0
#      be_reposted_count = 0
#      statuses_ids_str = statuses.map{|status|status.id}*","
#      # 所有 status 被转发和被评论的数目
#      comment_rt_count_arr = WeiboStatus.public_weibo.counts(:ids=>statuses_ids_str)
#      # 处理 original_count  repost_count
#      statuses.each do |status|
#        rs = status.retweeted_status
#        if rs.blank?
#          original_count+=1
#        else
#          repost_count+=1
#        end
#      end
#      # 处理 no_reply_count commented_count be_reposted_count
#      comment_rt_count_arr.each do |count_mash|
#        comments = count_mash.comments
#        rt = count_mash.rt
#      end
    end
  end

end
