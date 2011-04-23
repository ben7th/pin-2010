require "weibo"
class Tsina
  class OauthFailureError<StandardError;end

  SETTINGS = CoreService.find_setting_by_project_name(CoreService::USER_AUTH)
  CALLBACK_URL = SETTINGS["tsina_callback_url"]
  BIND_CALLBACK_URL = SETTINGS["tsina_bind_callback_url"]
  API_KEY = SETTINGS["tsina_api_key"]
  API_SECRET = SETTINGS["tsina_api_secret"]
  API_SITE = "http://api.t.sina.com.cn"

  def initialize
    @request_token = Tsina.get_request_token
  end
  
  def authorize_url
    @request_token.authorize_url({:oauth_callback=>Tsina::CALLBACK_URL})
  end

  def bind_authorize_url
    @request_token.authorize_url({:oauth_callback=>Tsina::BIND_CALLBACK_URL})
  end

  def request_token
    @request_token
  end

  # 得到一个 request_token
  def self.get_request_token
    consumer = OAuth::Consumer.new(API_KEY,API_SECRET,{:site=>API_SITE})
    consumer.get_request_token
  end

  # 根据 request_token 和 oauth_verifier
  # 得到授权后的 access_token
  # 用 access_token.token 和 access_token.secret 就可以使用用户的 新浪微博资源了
  def self.get_access_token_by_request_token_and_oauth_verifier(request_token,oauth_verifier)
    request_token.get_access_token(:oauth_verifier =>oauth_verifier)
  end

  # 用 access_token.token 和 access_token.secret 获取用户的 新浪微博信息
  def self.get_tsina_user_info_by_access_token(atoken,asecret)
    consumer = OAuth::Consumer.new(API_KEY,API_SECRET,{:site=>API_SITE})
    access_token = OAuth::AccessToken.new(consumer,atoken,asecret)
    xml = access_token.get("/account/verify_credentials.xml").body
    doc = Nokogiri::XML(xml)
    raise Tsina::OauthFailureError,"远程网站授权无效，认证失败" if !doc.at_css("error").blank?
    connect_id = doc.at_css("id").content
    user_name = doc.at_css("name").content
    profile_image_url = doc.at_css("profile_image_url").content
    followers_count = doc.at_css("followers_count").content
    friends_count = doc.at_css("friends_count").content
    statuses_count = doc.at_css("statuses_count").content
    {
      "connect_id"=>connect_id,"user_name"=>user_name,
      "profile_image_url"=>profile_image_url,"followers_count"=>followers_count,
      "friends_count"=>friends_count,"statuses_count"=>statuses_count
    }
  end

  module UserMethods
    def tsina_weibo
      cu = self.tsina_connect_user
      Weibo::Config.api_key = Tsina::API_KEY
      Weibo::Config.api_secret = Tsina::API_SECRET
      oauth = Weibo::OAuth.new(Weibo::Config.api_key,Weibo::Config.api_secret)
      oauth.authorize_from_access(cu.oauth_token ,cu.oauth_token_secret)
      Weibo::Base.new(oauth)
    end

    def send_message_to_tsina_weibo(content)
      wb = self.tsina_weibo
      wb.update(content)
      return true
    rescue Exception=>ex
      p ex.message
      puts ex.backtrace*"\n"
      return false
    end

    def share_mindmap_to_tsina_in_queue(mindmap)
      image = MindmapImageCache.new(mindmap).get_img_path_by("500x500")
      SendTsinaStatusQueue.new.add_task({
          :user_id=>self.id,:content=>"分享导图 #{mindmap.title}",
          :image_path=>image})
    end

    def send_mindmap_thumb_to_tsina_weibo(mindmap,content)
      image = MindmapImageCache.new(mindmap).get_img_path_by("500x500")
      send_tsina_image_status(image,content)
    end

    def send_tsina_image_status(image,content)
      wb = self.tsina_weibo
      File.open(image,"r") do |f|
        wb.upload(content,f)
      end
      return true
    rescue Exception=>ex
      p ex.message
      puts ex.backtrace*"\n"
      return false
    end
  end

end