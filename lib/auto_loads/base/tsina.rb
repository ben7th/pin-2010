class Tsina
  class OauthFailureError<StandardError;end
  class ContentLengthError<StandardError;end
  class RepeatSendError<StandardError;end

  API_KEY = "1526151944"
  API_SECRET = "a00a7048df478244376d69b14bb7ae07"
  API_SITE = "http://api.t.sina.com.cn"

  ACCOUNT_CONNECT_CALLBACK = pin_url_for("pin-user-auth","/account/tsina/callback")
  APP_DAOTU_CALLBACK = pin_url_for("pin-user-auth","/apps/tsina/tu/callback")
  APP_MINDPIN_CALLBACK = pin_url_for("pin-user-auth","/apps/tsina/mindpin/callback")
  APP_SCHEDULE_CALLBACK = pin_url_for("pin-user-auth","/apps/tsina/schedule/callback")

  def initialize
    @request_token = Tsina.get_request_token
  end
  
  def app_mindpin_authorize_url
    @request_token.authorize_url({:oauth_callback=>APP_MINDPIN_CALLBACK})
  end

  def account_connect_authorize_url
    @request_token.authorize_url({:oauth_callback=>ACCOUNT_CONNECT_CALLBACK})
  end

  def app_daotu_authorize_url
    @request_token.authorize_url({:oauth_callback=>APP_DAOTU_CALLBACK})
  end

  def app_schedule_authorize_url
    @request_token.authorize_url({:oauth_callback=>APP_SCHEDULE_CALLBACK})
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
      res = wb.update(content)
      res["id"]
    rescue Exception=>ex
      process_weibo_ex(ex)
    end

    def repost_message_to_tsina_weibo(id,content)
      wb = self.tsina_weibo
      res = wb.repost(id,:status=>content)
      res["id"]
    rescue Exception=>ex
      process_weibo_ex(ex)
    end

    def send_photo_to_tsina_weibo(photo_id,content)
      path = Photo.find(photo_id).image.to_file.path
      send_tsina_image_status(path,content)
    end

    def send_tsina_image_status(image,content)
      wb = self.tsina_weibo
      res = ""
      File.open(image,"r") do |f|
        res = wb.upload(content,f)
      end
      res["id"]
    rescue Exception=>ex
      process_weibo_ex(ex)
    end

    def process_weibo_ex(ex)
      p ex.message
      puts ex.backtrace*"\n"
      if !!ex.message.match("Text too long")
        raise Tsina::ContentLengthError
      elsif !!ex.message.match("accessor was revoked")
        raise Tsina::OauthFailureError
      elsif !!ex.message.match("repeated weibo text")
        raise Tsina::RepeatSendError
      end
    end

    def send_message_to_tsina_weibo_in_queue(content)
      SendTsinaStatusQueueWorker.async_send_tsina_status({
          :user_id=>self.id,:content=>content})
    end

    def send_tsina_image_status_in_queue(image_path,content)
      SendTsinaStatusQueueWorker.async_send_tsina_status({
          :user_id=>self.id,:content=>content,:image_path=>image_path})
    end

    def send_photo_to_tsina_in_queue(photo_id,content)
      SendTsinaStatusQueueWorker.async_send_tsina_status({
          :user_id=>self.id,:content=>content,:photo_id=>photo_id})
    end

  end

end