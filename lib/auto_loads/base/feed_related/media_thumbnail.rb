class MediaThumbnail < UserAuthAbstract
  HOST_XIAMI = "xiami"
  HOST_YOUKU = "youku"
  HOST_TUDOU = "tudou"

  MEDIA_HOSTS = [HOST_XIAMI,HOST_YOUKU,HOST_TUDOU]

  validates_presence_of :url
  validates_presence_of :thumb_src
  validates_presence_of :time
    validates_inclusion_of :host, :in=>MEDIA_HOSTS
  
  def self.get_thumb_src(url)
    media_thumbnail = self.find_by_url(url)
    return media_thumbnail.thumb_src unless media_thumbnail.blank?

    host = self.parse_for_host(url)
    data = self.parse(url,host)
    thumb_src = data[:thumb_src]
    time = data[:time]
    MediaThumbnail.create(:url=>url,:thumb_src=>thumb_src,:time=>time,:host=>host)

    thumb_src
  end

  def self.parse_for_host(url)
    uri = URI.parse(url)
    case uri.host
    when "v.youku.com"
      return HOST_YOUKU
    when "www.tudou.com"
      return HOST_TUDOU
    when "www.xiami.com"
      return HOST_XIAMI
    else
      return ""
    end
  end

  def self.parse(url,host)
    case host
    when HOST_YOUKU
      return YoukuParse.new(url).to_hash
    when HOST_TUDOU
      return TudouParse.new(url).to_hash
    when HOST_XIAMI
      return XiamiParse.new(url).to_hash
    else
      return {}
    end
  rescue Exception => ex
    return {}
  end
end
