class XiamiParse
def initialize(url)
    @url = url
    @content = open(url).read
    @doc = Nokogiri::HTML(@content)
  end

  def thumb_src
    @doc.at_css("a#albumCover img.cdCDcover185")["src"]
  end

  def time
    "00:00"
  end

  def to_hash
    {
      :thumb_src => thumb_src,
      :time          => time
    }
  end
end
