require "douban"
class MDouban

  SETTINGS = CoreService.find_setting_by_project_name(CoreService::USER_AUTH)
  CALLBACK_URL = ""
  API_KEY = SETTINGS["douban_api_key"]
  API_SECRET = SETTINGS["douban_api_secret"]

  def initialize
    @douban = _douban
  end

  def authorize_url
    @authorize_url ||= @douban.get_authorize_url(CALLBACK_URL)
  end

  def request_token
    authorize_url
    @douban.request_token :as_token
  end
  
  def get_access_token_by_request_token(request_token)
    @douban.request_token = request_token
    @douban.auth
    @douban.access_token :as_token
  end

  def get_user_info(atoken,asecret)
    @douban.access_token = OAuth::Token.new(atoken,asecret)
    people = @douban.get_people
    {"connect_id"=>people.uid,"user_name"=> people.title,
      "logo_url"=>people.link["icon"]
    }
  end

  def _douban
    Douban::Authorize.new(API_KEY,API_SECRET)
  end

  class Event
    attr_reader :title,:summary,:content,:author_name,:author_uri,:id
    def initialize(id)
      @id = id
      parse_info
    end

    def parse_info
      doc = Nokogiri::XML(open("http://api.douban.com/event/#{@id}"))
      @title = doc.at_css("entry title").content
      @summary = doc.at_css("entry summary").content
      @content = doc.at_css("entry content").content
      @author_name = doc.at_css("entry author name").content
      @author_uri = doc.at_css("entry author uri").content
    end
  end
end
