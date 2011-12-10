class TudouParse
  def initialize(url)
    @url = url
    @content = open(url).read
    @doc = Nokogiri::HTML(@content)
  end

  def thumb_src
  end

  def time
  end

  def to_hash
    {
      :thumb_src => thumb_src,
      :time          => time
    }
  end
end
