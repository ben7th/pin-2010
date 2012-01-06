module AuthenticatedSystem

  public
  
  # 当某个controller需要登录验证时，加上这个 before_filter
  def login_required(info=nil)
    logged_in? || access_denied(info)
  end

  private

    # 根据session里的信息，获取当前登录用户
    # 如果没有登录，则返回 nil
    def current_user
      @current_user ||= (
        login_from_session || login_from_cookie
      ) unless @current_user == false
    end

    # 设定指定对象为当前会话用户对象，并将基本信息传入session保存
    def current_user=(user)
      session[:user_id] = (user.blank? ? nil : user.id)
      @current_user = user || false
    end

    # 判断用户是否登录，同时预加载 @current_user 对象
    def logged_in?
      !!current_user
    end

    def access_denied(info)
      if request.xhr?
        render :status=>401, :text=>"ACCESS DENIED 请求需要登录 #{info}"
      else
        store_location
        flash[:notice] = info
        redirect_to pin_url_for('pin-user-auth','login'), :status=>302
      end
    end

    # 记录下access denied 重定向前试图访问的URL
    def store_location
      session[:return_to] = request.url
    end

    # 重定向到之前 store_location 记录的URL
    def redirect_back_or_default(default)
      url = session[:return_to] || default
      redirect_to url, :status=>302
      session[:return_to] = nil
    end

    # 将几个方法添加到helper方法中，以便在页面使用
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?
    end

    # Called from #current_user.  First attempt to login by the user id stored in the session.
    def login_from_session
      begin
        self.current_user = User.find(session[:user_id]) if session[:user_id]
      rescue MemCache::MemCacheError=>ex
        raise MemCache::MemCacheError, ex.message
      rescue Exception=>ex
        nil
      end
    end

    def remember_me_cookie_key
      return :remember_me_token if Rails.env.production?
      return :remember_me_token_devel
    end

    # 被 current_user 方法调用 如果登录时勾选了 记住我，此方法会生效
    def login_from_cookie
      if cookies[remember_me_cookie_key]
        user = User.authenticate_cookies_token(cookies[remember_me_cookie_key])
        self.current_user = user if user
      end
    end
  
end