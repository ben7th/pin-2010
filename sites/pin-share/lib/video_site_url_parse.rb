class VideoSiteUrlParse
  require "open-uri"
  # 返回结果 {:video_html=>"",:image_src=>"",:title=>""}
  def self.parse_url(url)
    parse_url = self.parse_youku_url(url)
    parse_url = self.parse_tudou_url(url) if parse_url.nil?
    parse_url = self.parse_ku6_url(url) if parse_url.nil?
    parse_url = self.parse_sina_url(url) if parse_url.nil?
    return parse_url
  end

  private
  def self.parse_youku_url(url)
    match = url.match(/http:\/\/v.youku.com\/v_show\/id_([\w]+).html/)
    if match
      sid = match[1]
      video_src = "http://player.youku.com/player.php/sid/#{sid}/v.swf"
      content = Nokogiri::XML(open(url))
      title = content.css('title')[0].text
      image_src = content.css("#download").first["href"].split("|").last
      return {:video_src=>video_src,:image_src=>image_src,:title=>title}
    end
    return nil
  end

  def self.parse_tudou_url(url)
    match = url.match(/http:\/\/www.tudou.com\/programs\/view\/([\w]+)\/?/)
    if match
      sid = match[1]
      content = open(url).lines.to_a*""
#      content.gsub!("<!DOCTYPE html>","<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Strict//EN' ' http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'>")
#      content.gsub!("<html>","<html xmlns='http://www.w3.org/1999/xhtml'> ")
      title = Nokogiri::HTML(content,nil,'gbk').css('title')[0].text
      image_src = Nokogiri::HTML(content).css("span.s_pic").inner_html
      video_src = "http://www.tudou.com/v/#{sid}"
      return {:video_src=>video_src,:image_src=>image_src,:title=>title}
    end
    return nil
  end

  def self.parse_ku6_url(url)
    match = url.match(/http:\/\/v.ku6.com\/show\/([\w]+).html/)
    if match
      sid = match[1]
      video_src = "http://player.ku6.com/refer/#{sid}/v.swf"
      content = Nokogiri::XML(open(url))
      title = content.css('title')[0].text.gbk_to_utf8
      image_src = content.css("span.s_pic").inner_html
      return {:video_src=>video_src,:image_src=>image_src,:title=>title}
    end
    return nil
  end

  def self.parse_sina_url(url)
    match = url.match(/http:\/\/you.video.sina.com.cn\/b\/([0-9]+)-([0-9]+).html(.*)/)
    if match
      vid = match[1]
      uid = match[2]
      video_src = %`
        http://p.you.video.sina.com.cn/player/outer_player.swf?auto=1&vid=#{vid}&uid=#{uid}
      `
      content = Nokogiri::XML(open(url))
      title = content.css("title")[0].text
      image_src = content.css("script[type='text/javascript']")[10].inner_html.match(/pic:[ ]*'(.*)'/)[1]
      return {:video_src=>video_src,:image_src=>image_src,:title=>title}
    end
    return nil
  end
end