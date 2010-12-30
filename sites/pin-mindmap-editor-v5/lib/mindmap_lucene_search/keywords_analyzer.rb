class KeywordsAnalyzer
  #从这里产生出最高频词，然后使用搜索引擎进行搜索

  def initialize(text)
    @text = text
  end

  def words
    @words ||= MindmapLucene.split_words(@text)
  end

  def major_words(words_count=5)
    _major_words(words_count)
  end

  private
  # 取得一组词频浮点计数中的最高频词，返回数组
  # {"a"=>1.1,"b"=>2.2,"c"=>3.3,"d"=>4.4,"e"=>5.5,"f"=>6.6} => ["f","e","d","c","b"]
  def _major_words(words_count)
    _arr = _words_frequency.sort{|a,b| b[1]<=>a[1]}[0...words_count]
    _arr.map {|k_v| k_v[0]}
  end

  # 获取 一段文本中 每个词出现的频率，以浮点数表示
  # {"xx"=>0.5,"yy"=>0.5}
  # ["a","b","c","c"] => {"a"=>0.25,"b"=>0.25,"c"=>0.5}
  def _words_frequency
    @words_frequency ||= begin
      words_count = words.size
      
      frequency_hash = {}
      _words_times.each do |word,times|
        # 单词出现的次数/总词数 = 出现频率
        frequency_hash[word] = times.to_f / words_count.to_f
      end
      frequency_hash
    end
  end

  # ["a","b","c","c"] => {"a"=>1,"b"=>1,"c"=>2}
  def _words_times
    @words_times ||= begin
      times_hash = Hash.new(0)
      words.each do |word|
        times_hash[word] = times_hash[word] + 1
      end
      times_hash
    end
  end
end
