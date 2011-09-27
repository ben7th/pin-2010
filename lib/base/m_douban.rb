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
    attr_reader :title,:summary,:content,:author_name,:author_uri,
      :where,:location,:start_time,:end_time
    def initialize(options)
      options.each do |key,value|
        instance_variable_set("@#{key.to_s}".to_sym, value)
      end
    end

    def self.get_by_id(id)
      doc = Nokogiri::XML(open("http://api.douban.com/event/#{id}"))
      title = doc.at_css("entry title").content
      summary = doc.at_css("entry summary").content
      content = doc.at_css("entry content").content
      author_name = doc.at_css("entry author name").content
      author_uri = doc.at_css("entry author uri").content

      where = doc.at_css("entry gd|where")["valueString"]
      location = doc.at_css("entry db|location").content
      gb_when = doc.at_css("entry gd|when")
      start_time = gb_when["startTime"]
      end_time = gb_when["endTime"]
      self.new(:title=>title,:summary=>summary,:content=>content,:author_name=>author_name,
        :author_uri=>author_uri,:where=>where,:location=>location,
        :start_time=>start_time,:end_time=>end_time
      )
    end

    def self.build_by_location(location)
      doc = Nokogiri::XML(open("http://api.douban.com/event/location/#{location}"))
      doc.css("entry").map do |entry|
        title = entry.at_css("title").content
        summary = entry.at_css("summary").content
        content = entry.at_css("content").content

        where = entry.at_css("gd|where")["valueString"]
        elocation = entry.at_css("db|location").content
        gb_when = entry.at_css("gd|when")
        start_time = gb_when["startTime"]
        end_time = gb_when["endTime"]
        self.new(:title=>title,:summary=>summary,:content=>content,
          :where=>where,:location=>elocation,
          :start_time=>start_time,:end_time=>end_time
        )
      end
    end
  end
end
