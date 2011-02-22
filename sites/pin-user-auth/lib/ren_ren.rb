require 'md5'
class RenRen

  SETTINGS = CoreService.find_setting_by_project_name(CoreService::USER_AUTH)
  CALLBACK_URL = SETTINGS["renren_callback_url"]
  API_KEY = SETTINGS["renren_api_key"]
  API_SECRET = SETTINGS["renren_api_secret"]
  
  def authorize_url
    "http://graph.renren.com/oauth/authorize?response_type=code&client_id=#{API_KEY}&redirect_uri=#{CALLBACK_URL}"
  end

  def get_access_token(authorization_code)
    access_token_url = "http://graph.renren.com/oauth/token?client_id=#{API_KEY}&client_secret=#{API_SECRET}&redirect_uri=#{CALLBACK_URL}&grant_type=authorization_code&code=#{authorization_code}"
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

    Net::HTTP.post_form(URI.parse('http://api.renren.com/restserver.do'),{
        'api_key'=>API_KEY,
        'method'=>'users.getInfo',
        'call_id'=>call_id,
        'v'=>'1.0',
        'uids'=>uid,
        'session_key'=>session_key,
        'sig'=>user_info_sig(call_id,session_key,uid)}).body
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
