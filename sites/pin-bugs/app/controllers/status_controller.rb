class StatusController < ApplicationController

  def index
    @responses = get_response
    p @responses
  end

  def get_response
    URLS[RAILS_ENV].map do |key,value|
      hash = {}
      begin
        response = HandleGetRequest.get_response(value)
        hash = {:key=>key,:code=>response.code,:message=>response.message,:time=>response["x-runtime"]}
      rescue Exception=>ex
        hash.merge!(:error=>"#{key} 访问时出现异常，#{ex.message}")
      end
      hash
    end
  end
end
