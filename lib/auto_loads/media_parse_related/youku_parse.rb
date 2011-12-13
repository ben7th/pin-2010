class YoukuParse
  def initialize(url)
    @url = url
    parse
  end

  def thumb_src
    @thumb_src
  end

  def time
    @time
  end

  def to_hash
    {
      :thumb_src => thumb_src,
      :time          => time
    }
  end

  private
  def parse
    case @url
    when /v_show/
      parse_show
    when /v_playlist/
      parse_playlist
    else
      raise "不支持的地址"
    end
  end

  def parse_playlist
    doc = Nokogiri::HTML(open(@url).read)

    href = doc.at_css("a#s_sina")["href"]
    @thumb_src = href[href.index("pic=")..-1].split("=")[1]

    href = doc.at_css("a#download")["_href"]
    @time = href.split("|")[4]
  end

  def parse_show
    id = @url.match(/v_show\/id_([^.]*).htm/)[1]
    content = open("http://v.youku.com/player/getPlayList/VideoIDS/#{id}").read
    json = ActiveSupport::JSON.decode(content)
    @thumb_src = json["data"][0]["logo"].gsub("/1","/0")
    @time = convert_minute(json["data"][0]["seconds"])
  end
  
  def convert_minute(seconds)
    minute = seconds.to_i/60

    sec = seconds.to_i-minute*60
    "#{sprintf("%02d", minute)}:#{sprintf("%02d",sec)}"
  end
end
