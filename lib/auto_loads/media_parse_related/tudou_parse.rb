class TudouParse
  def initialize(url)
    @url = url
    @uri = URI.parse(@url)
    @content = get_body
    @doc = Nokogiri::HTML(@content)
    parse
  end

  def parse
    case @uri.path
    when /playlist/
      parse_playlist
    when /programs/
      parse_programs
    else
      raise "不支持的地址"
    end
  end
  
  def parse_playlist
    json = @doc.at_css("script").match(/listData = (\[[^\]]*\])/m)[1]
    json.split("},{").map{|str|{:iid=>str.match(/iid:(.*)\n,/)[1],:pic=>str.match(/pic:"(.*)"/)[1]}}
    iid = File.basename(@uri.path).split(".").first.split(/i|l/)[2]
  end

  def parse_programs
    @thumb_src = @doc.at_css("script").inner_html.match(/pic = '(.*)'/)[1]
    @time = @doc.at_css("script").inner_html.match(/time = '(.*)'/)[1]
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
  def get_body
    site = Net::HTTP.new(@uri.host, @uri.port)
    site.open_timeout = 20
    site.read_timeout = 20
    path = @uri.query.blank? ? @uri.path : @uri.path+"?"+@uri.query
    resp = site.get2(path,{'user-agent'=>'Mozilla/5.0'})
    if resp["Content-Encoding"] == "gzip"
      return Zlib::GzipReader.new(StringIO.new(resp.body)).read
    else
      return resp.body
    end
  end
end
