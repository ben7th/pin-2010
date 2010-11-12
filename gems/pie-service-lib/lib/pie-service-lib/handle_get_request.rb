class HandleGetRequest
  # 对url发起get请求
  require 'net/http'

  def self.get_response_from_url(url)
    begin
      response = self.get_response(url)
      return handle_with_response(response,url)
    rescue Exception => ex
#      p ex
      return ""
    end
  end

  def self.get_response(url)
    begin
      url_str = URI.parse(url)
      site = Net::HTTP.new(url_str.host, url_str.port)
      site.open_timeout = 20
      site.read_timeout = 20
      path = url_str.query.blank? ? url_str.path : url_str.path+"?"+url_str.query
      return site.get2(path,{'accept'=>'text/html','user-agent'=>'Mozilla/5.0'})
    rescue Exception => ex
#      raise ex
      return ""
    end
  end

  # 根据get请求的回应处理返回的response
  def self.handle_with_response(response,url)
    case response
    when Net::HTTPSuccess,Net::HTTPOK
      web_content = response.body
      return web_content
    when Net::HTTPRedirection
      raise '循环重定向' if response['location'] == url
      get_response_from_url(response['location'])
    else
      return ''
      raise "链接问题"
    end
  end
  
end
