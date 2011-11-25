require 'md5'
class RenRen

  CALLBACK_URL = pin_url_for("pin-user-auth","/connect_renren_callback")
  BIND_CALLBACK_URL = pin_url_for("pin-user-auth","/bind_other_site/renren_callback")
  API_KEY = "e7533b7ee8b541878000455b20b3589b"
  API_SECRET = "7317a969ef764953a5b22e5862a27c0b"
  
  def authorize_url
    "http://graph.renren.com/oauth/authorize?response_type=code&client_id=#{API_KEY}&redirect_uri=#{CALLBACK_URL}"
  end

  def bind_authorize_url
    "http://graph.renren.com/oauth/authorize?response_type=code&client_id=#{API_KEY}&redirect_uri=#{BIND_CALLBACK_URL}"
  end

  def get_access_token(authorization_code)
    access_token_url = "http://graph.renren.com/oauth/token?client_id=#{API_KEY}&client_secret=#{API_SECRET}&redirect_uri=#{CALLBACK_URL}&grant_type=authorization_code&code=#{authorization_code}"
    access_token = HandleGetRequest.get_response_from_url(access_token_url)
    access_token_hash = ActiveSupport::JSON.decode(access_token)
    access_token_hash["access_token"]
  end

  def get_bind_access_token(authorization_code)
    access_token_url = "http://graph.renren.com/oauth/token?client_id=#{API_KEY}&client_secret=#{API_SECRET}&redirect_uri=#{BIND_CALLBACK_URL}&grant_type=authorization_code&code=#{authorization_code}"
    access_token = HandleGetRequest.get_response_from_url(access_token_url)
    access_token_hash = ActiveSupport::JSON.decode(access_token)
    access_token_hash["access_token"]
  end

  def get_session_key(access_token)
    get_session_key_and_uid(access_token)['session_key']
  end

  def get_user_info(access_token)
    sesson_hash = get_session_key_and_uid(access_token)
    session_key = sesson_hash['session_key']
    uid = sesson_hash['uid']
    call_id = Time.now.to_i

    user_info_xml = Net::HTTP.post_form(URI.parse('http://api.renren.com/restserver.do'),{
        'api_key'=>API_KEY,
        'method'=>'users.getInfo',
        'call_id'=>call_id,
        'v'=>'1.0',
        'uids'=>uid,
        'session_key'=>session_key,
        'sig'=>user_info_sig(call_id,session_key,uid)}).body

    doc = Nokogiri::XML(user_info_xml)
    connect_id = doc.at_css("uid").content
    user_name = doc.at_css("name").content
    logo_url = doc.at_css("tinyurl").content
    sex = doc.at_css("sex").content
    star = doc.at_css("star").content
    dom = doc.at_css("university_info name")
    university_name = dom.blank? ? "" : dom.content
    {"connect_id"=>connect_id,"user_name"=>user_name,"logo_url"=>logo_url,
      "sex"=>sex,"star"=>star,"university_name"=>university_name
    }
  end

  def get_session_key_and_uid(access_token)
    uri = URI.encode("http://graph.renren.com/renren_api/session_key?oauth_token=#{access_token}")
    hash_json = HandleGetRequest.get_response_from_url(uri)
    session_hash = ActiveSupport::JSON.decode(hash_json)
    uid = session_hash["user"]["id"]
    session_key = session_hash["renren_token"]["session_key"]
    {'uid'=>uid,'session_key'=>session_key}
  end

  private
  def user_info_sig(call_id,session_key,uid)
    str = "api_key=#{API_KEY}call_id=#{call_id}method=users.getInfosession_key=#{session_key}uids=#{uid}v=1.0#{API_SECRET}"
    MD5.hexdigest(str)
  end
end
