class StatusController < ApplicationController

  def index
    p "asdhfajsdhfsdhgfahsdgfh"
    get_response
  end

  def get_response
    URLS[RAILS_ENV].each do |key,value|
      begin
        p value
        response = HandleGetRequest.get_response(value)
        p response.status
        p response
      rescue Exception=>ex
        p "#{key} 访问时出现错误，#{ex.message}"
      end
    end
  end
end
