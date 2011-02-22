class ConnectUsersController < ApplicationController
  def index
  end

  def connect_sina
#    consumer = OAuth::Consumer.new(2802132691,"94d47028669189b276eb66573c7d2bcb",{:site=>"http://api.t.sina.com.cn"})
    consumer = OAuth::Consumer.new(SinaWeibo::API_KEY,SinaWeibo::API_SECRET,{:site=>"http://api.t.sina.com.cn"})
    request_token = consumer.get_request_token
    session[:request_token] = request_token
#    redirect_to request_token.authorize_url({:oauth_callback=>"http://dev.www.mindpin.com/connect_sina_callback"})
    redirect_to request_token.authorize_url({:oauth_callback=>SinaWeibo::CALLBACK_URL})
  end

  def connect_sina_callback
    request_token = session[:request_token]
    access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
    get_and_set_sinat_user_info(access_token)
    session[:request_token] = nil
    render :text=>%`
      <script>
        window.opener.location = window.opener.location;
        window.close();
      </script>
    `
  end

  def get_and_set_sinat_user_info(access_token)
    self.current_user = ConnectUser.set_sina_connect_user(access_token)
  end

  def connect_renren
    redirect_to RenRen.new.authorize_url
  end

  def connect_renren_callback
    renren = RenRen.new
    access_token = renren.get_access_token(params[:code])
    user_info_xml = renren.get_user_info(access_token)
    self.current_user = ConnectUser.set_renren_connect_user(user_info_xml)
      render :text=>%`
          <script>
            window.opener.location = window.opener.location;
            window.close();
          </script>
      `
  end


end