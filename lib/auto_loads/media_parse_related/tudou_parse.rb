class TudouParse
  def initialize(url)
    @url = url
    @uri = URI.parse(@url)
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

  def parse
    case @url
    when /playlist/
      parse_playlist
    when /programs/
      parse_programs
    else
      raise "不支持的地址"
    end
  end

  def parse_playlist
    doc = Nokogiri::HTML(get_body)
    json = doc.at_css("script").inner_html.match(/listData = (\[[^\]]*\])/m)[1]
    data = json.split("},{").map do |str|
      iid = str.match(/iid:(.*)\n,/)[1]
      pic = str.match(/pic:"(.*)"/)[1]
      time = str.match(/time:"(.*)"/)[1]
      {:iid=>iid,:pic=>pic,:time=>time}
    end
    iid = File.basename(@uri.path).split(".").first.split(/i|l/)[2]
    if iid.blank?
      hash = data.first
      @thumb_src = hash[:pic]
      @time = hash[:time]
    else
      data.each do |hash|
        if hash[:iid] == iid
          @thumb_src = hash[:pic]
          @time = hash[:time]
          return
        end
      end
    end
  end

  def parse_programs
#    http://www.tudou.com/programs/view/LKHAxPz1CrY/
    id = @url.match(/programs\/view\/([^\/]*)/)[1]
    content = open("http://api.tudou.com/v3/gw?method=item.info.get&appKey=acdec9d9af7be796&format=json&itemCodes=#{id}").read
    json = ActiveSupport::JSON.decode(content)
    @thumb_src = json["multiResult"]["results"][0]["picUrl"]
    @time = convert_minute(json["multiResult"]["results"][0]["totalTime"])
  end

  def convert_minute(milli_second)
    seconds = milli_second.to_i/1000
    minute = seconds.to_i/60
    
    sec = seconds.to_i-minute*60
    "#{sprintf("%02d", minute)}:#{sprintf("%02d",sec)}"
  end
end
