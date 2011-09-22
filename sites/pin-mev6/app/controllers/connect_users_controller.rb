class ConnectUsersController < ApplicationController

  def connect_tsina
    if logged_in?
      return render_status_page(401,"你已经登录过了")
    end
    tsina = Tsina.new
    session[:request_token] = tsina.request_token
    redirect_to tsina.tu_authorize_url
  end
end