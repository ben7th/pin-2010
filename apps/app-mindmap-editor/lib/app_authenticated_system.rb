module AppAuthenticatedSystem

  private
  # Returns true or false if the user is logged in.
  # Preloads @current_user with the user model if they're logged in.
  def logged_in?
    !!current_user
  end

  # Accesses the current user from the session. 
  # Future calls avoid the database because nil is not equal to false.
  def current_user
    @current_user ||= (login_from_mindpin_app_auth) unless @current_user == false
  end

  # 设定指定对象为当前会话用户对象
  def current_user=(user)
    @current_user = user || false
  end
  
  # Check if the user is authorized
  #
  # Override this method in your controllers if you want to restrict access
  # to only a few actions or if you want to check if the user
  # has the correct rights.
  #
  # Example:
  #
  #  # only allow nonbobs
  #  def authorized?
  #    current_user.login != "bob"
  #  end
  def authorized?
    logged_in?
  end

  public
  def login_required(info=nil)
    authorized? # || access_denied(info)
  end

  private
  
  # Inclusion hook to make #current_user and #logged_in?
  # available as ActionView helper methods.
  def self.included(base)
    base.send :helper_method, :current_user, :logged_in?, :admin_authorization
  end

  def login_from_mindpin_app_auth
    secret_key = SECRET_KEY
    req_user_id = params[:req_user_id]
    app_token = params[:app_token]
    # 根据 req_user_id 和 app_token_key 计算 token 看是否与 app_token 相等
    token = sha1_app_token(req_user_id,secret_key)
    if(token == app_token)
      return User.find(req_user_id)
    end
    return false
  end

  require 'digest/sha1'
  def sha1_app_token(user_id,token_key)
    if user_id.blank?
      ''
    else
      Digest::SHA1.hexdigest(user_id.to_s + token_key)
    end
  end
end
