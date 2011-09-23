class ConnectTsinaController < ApplicationController

  # 首页上点使用新浪微博连接按钮时访问此action
  def index
    if logged_in?
      return render_status_page(401,"你已经登录过了")
    end
    tsina = Tsina.new
    session[:request_token] = tsina.request_token
    redirect_to tsina.tu_authorize_url
  end
end