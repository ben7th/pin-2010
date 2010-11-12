class App < ActiveRecord::Base
  include DispatchHttp
  has_many :installings
  has_many :users,:through=>:installings,:source=>:user
  validates_presence_of :name
  validates_presence_of :title
  validates_presence_of :callback_url
  validates_uniqueness_of :name
  MINDMAP_EDITOR = "mindmap_editor"

  if RAILS_ENV == "development"
    MINDMAP_EDITOR = "mindmap_editor"
  end

  ATTACHED_FILE_PATH_ROOT = UserBase::LOGO_PATH_ROOT
  ATTACHED_FILE_URL_ROOT = UserBase::LOGO_URL_ROOT


  MINDMAP_EDITOR_APP = App.find_by_name(MINDMAP_EDITOR)
  if MINDMAP_EDITOR_APP
    MINDMAP_EDITOR_CALLBACK_URL = "http://#{MINDMAP_EDITOR_APP.callback_url}"
    MINDMAP_EDITOR_SITE = (MINDMAP_EDITOR_APP.port == 80) ? MINDMAP_EDITOR_CALLBACK_URL : "#{MINDMAP_EDITOR_CALLBACK_URL}:#{MINDMAP_EDITOR_APP.port}"
  end


  # logo
  @logo_path = "#{ATTACHED_FILE_PATH_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  @logo_url = "#{ATTACHED_FILE_URL_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  has_attached_file :logo,:styles => {:s300=>'300x300>',:s64=>"64x64#",:s32=>'32x32#'},
    :path => @logo_path,
    :url => @logo_url,
    :default_url => "/images/logo/default_:class_:style.png",
    :default_style => :s64

  # 设置secret_key
  before_create :set_secret_key
  def set_secret_key
    self.secret_key = randstr(16)
  end

  #  对app的指定path发起get请求，并返回response
  def open_path(request,user=nil)
    re = open_path_raw(request,user)
    return MPML.new(self,re).body
  end

  def open_path_raw(request,user=nil)
    req_path = _path(request)
    url = self.callback_url
    port = self.port
    path = _pack_app_path(req_path,user)
    method = request.method
    return _handle_req(url,path,port,request,method)
  end

  def open_path_raw_response(request,user=nil)
    req_path = _path(request)
    url = self.callback_url
    port = self.port
    path = _pack_app_path(req_path,user)
    method = request.method
    return _handle_req(url,path,port,request,method,true)
  end

  # 处理 各种 请求
  def _handle_req(url,path,port,request,method,raw=false)
    response = dispatch_http(url,path,port,request,method)
    if raw
      return response
    else
      return _handle_response(response)
    end
  end

  def _handle_response(response)
    re = case response
    when Net::HTTPSuccess
      response.body
    when Net::HTTPRedirection
      raise HasToBeRedirect,replace_redirect_url(response['location'].remove_mindpin_token)
    when Net::HTTPServerError
      "<div class='padding10'><div class='flash-error font14'>应用程序错误 <b>#{response.code}</b></div></div>"
    else
      "<div class='padding10'><div class='flash-error font14'>服务请求失败：状态码 <b>#{response.code}</b></div></div>"
    end
    return re,response.code
  end

  def replace_redirect_url(url)
    callback_url = self.callback_url
    p = self.port
    str = (p == 80 ? callback_url : "#{callback_url}:#{port}")
    url.sub("http://#{str}","/app/#{self.name}")
  end

  # 把 user id 作为参数 拼接在 path 后边
  def _pack_app_path(path,user)
    return "/#{path}" if user.blank?
    _path = path.
      add_url_param('req_user_id',user.id).
      add_url_param('app_token',sha1_app_token(user)).
      add_url_param('api_token',sha1_api_token(user)).
      add_url_param('app',self.name)
    return "/#{_path}"
  end

  def _path(request)
    path = request.params[:path]
    if (uri = request.request_uri).include?('?')
      path += ('?'+uri.split('?')[-1])
    end
    # 为了解决某问题加的
    # 加上后引发了 另一个问题 ,会把?q=1+2 unescape成 ?q=1 2
    # 导致平台发给应用的 http 报文 有错误
    # 现在不知道以前的某个问题是什么，先注释掉
    #    path = CGI.unescape path
    return path
  end

  def _request_is_api?(request)
    _path(request).split('/')[0] == 'api'
  end

  class HasToBeRedirect < StandardError
    def url
      self.message
    end
  end

  def get_user_from_api_token(user_id,token)
    user = User.find(user_id)
    if sha1_api_token(user) == token
      return user
    end
    return nil
  end

  private
  # 生成token
  def sha1_app_token(user)
    Digest::SHA1.hexdigest("#{user.id}#{self.secret_key}")
  end

  def sha1_api_token(user)
    Digest::SHA1.hexdigest("#{user.id}#{self.secret_key}mindpinapi")
  end

  module UserMethods
    def self.included(base)
      base.has_many :installings
      base.has_many :apps,:through=>:installings,:source=>:app
    end

    # 是否安装了 思维导图应用
    def installed_mindmap?
      install_app?(App::MINDMAP_EDITOR)
    end

    # 安装 思维导图 并设置为常用
    def install_mindmap_to_usually
      mindmap_app = App.find_by_name("mindmap_editor")
      install = self.installings.find_or_create_by_app_id(mindmap_app.id)
      install.update_attributes(:usually_used=>true)
    end

    # 已经安装的apps
    def installed_apps
      self.apps.uniq
    end

    # 检查用户是否安装了某应用（例如 mindmap_editor）
    def install_app?(app_name)
      app = App.find_by_name(app_name)
      self.apps.include?(app)
    end

    def default_app
      default_installing = self.installings.is_default.first
      return default_installing.app if default_installing
      return nil
    end

    def usually_used_apps
      self.installings.usually_used.map{|ist|ist.app}
    end

    def set_usually_used_app_ids=(app_ids)
      clear_usually_used_apps
      return if app_ids.blank?
      app_ids.each do |app_id|
        set_installing = self.installings.app_id_equals(app_id).first
        if set_installing
          set_installing.update_attributes(:usually_used=>true)
        end
      end
    end

    def default_app_id=(app_id)
      clear_default_app
      return if !app_id
      set_installing = self.installings.app_id_equals(app_id).first
      if set_installing
        return set_installing.update_attributes(:is_default=>true)
      end
      return false
    end

    def clear_default_app
      default_installings = self.installings.is_default
      default_installings.each do |di|
        di.update_attributes!(:is_default=>false)
      end
    end

    def clear_usually_used_apps
      usually_used_installings = self.installings.usually_used
      usually_used_installings.each do |uui|
        uui.update_attributes!(:usually_used=>false)
      end
    end

  end
end