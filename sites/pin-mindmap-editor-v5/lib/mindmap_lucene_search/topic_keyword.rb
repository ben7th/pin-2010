class TopicKeyword

  # 获取 一段文本中 每个词出现的频率
  # {"xx"=>0.5,"yy"=>0.5}
  def self.parse(text)
    keywords = self.get_keywords(text)
    self._word_frequency(keywords)
  end

  # 获得 一段文本中 出现 频率最高 的几个词
  def self.major_words(text,count=5)
    hash = self.parse(text)
    self.hash_to_major_words(hash,count)
  end

  private

  # 把整段文本分成 分词 (没有去掉重复)
  def self.get_keywords(text)
    MindmapLucene.parse_content(text)
  end

  # {"a"=>1,"b"=>2,"c"=>3,"d"=>4,"e"=>5,"f"=>6} => ["b","c","d","e","f"]
  def self.hash_to_major_words(hash,count=5)
    arr = hash.sort {|a,b| b[1]<=>a[1]}
    arr[0...count].map do |k_v_a|
      k_v_a[0]
    end
  end

  # ["a","b","c","c"] => {"a"=>0.25,"b"=>0.25,"c"=>0.5}
  def self._word_frequency(arr)
    all_count = arr.size.to_f
    word_hash = self._number_of_times_with_word(arr)
    word_hash.each do |key,value|
      word_hash[key] = value/all_count
    end
    word_hash
  end

  # ["a","b","c","c"] => {"a"=>1,"b"=>1,"c"=>2}
  def self._number_of_times_with_word(arr)
    word_hash = {}
    arr.each do |str|
      if word_hash[str].blank?
        word_hash[str] = 1
      else
        word_hash[str] = (word_hash[str] + 1)
      end
    end
    word_hash
  end

end
#      p "#{tok.text} [#{tok.start}...#{tok.end}]"
