class YoukuParse
  def initialize(url)
    @url = url
    @content = open(url).read
    @doc = Nokogiri::HTML(@content)
  end
  
  def thumb_src
    href = @doc.at_css("a#s_sina")["href"]
    href[href.index("pic=")..-1].split("=")[1]
  end

  def time
    href = @doc.at_css("a#download")["_href"]
    href.split("|")[4]
  end

  def to_hash
    {
      :thumb_src => thumb_src,
      :time          => time
    }
  end
end
