class Bug < ActiveRecord::Base
  
  apply_simple_captcha :message=>"验证码错误",:add_to_base=>true
  belongs_to :user
  
  ERROR = "error"
  PROPOSITION = "proposition"

  validates_presence_of :content
  #  validates_presence_of :kind
  #  validates_inclusion_of :kind, :in => [ERROR,PROPOSITION]

  # 返回bug类型的说明
  def type_str
    case kind
    when 'error'
      return '程序错误'
    when 'proposition'
      return '功能建议'
    end
  end

  if RAILS_ENV == "test"
    ATTACHED_FILE_PATH_ROOT = "/tmp/"
    ATTACHED_FILE_URL_ROOT = "http://localhost"
  else
    SETTINGS = YAML.load(CoreService.project(CoreService::USER_AUTH).settings)
    ATTACHED_FILE_PATH_ROOT = SETTINGS["user_logo_file_path_root"]
    ATTACHED_FILE_URL_ROOT = SETTINGS["user_logo_file_url_root"]
  end

  # attachment
  @attachment_path = "#{ATTACHED_FILE_PATH_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  @attachment_url = "#{ATTACHED_FILE_URL_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  has_attached_file :attachment,:styles => {:raw=>'500x500>',:medium=>"96x96>",:normal=>"48x48#",:tiny=>'32x32#',:mini=>'24x24#' },
    :path => @attachment_path,
    :url => @attachment_url

  # 处理
  def handled!
    self.update_attributes(:handled=>true)
  end

  # 发送反馈邮件
  def send_email_of_thanks(comment)
    # 如果是匿名用户发表的留言，那么不发送邮件
    return if self.user.blank?
    begin
      Mailer.deliver_respond_to_bug_commmiter(self,comment)
    rescue Exception=>e
      p e
    rescue Net::SMTPFatalError
      p "Net::SMTPFatalError"
    rescue Net::SMTPServerBusy, Net::SMTPUnknownError, Net::SMTPSyntaxError, TimeoutError
      p "Net::SMTPServerBusy, Net::SMTPUnknownError, Net::SMTPSyntaxError, TimeoutError"
    end
  end

  # 关闭
  def closed!
    self.update_attributes(:closed=>true)
  end

  # 返回ip地址的 111.111.111.* 这种形式
  def handled_user_ip
    if self.user_ip
      ips = self.user_ip.split('.')
      ips[-1] = '*'
      return ips*('.')
    end
    return "匿名"
  end

  # 根据bug中保存的user_agent获取浏览器的版本
  def browser_type
    agent_str = self.user_agent
    return "" if agent_str.nil?
    if agent_str.match("MSIE")
      return agent_str.match(/MSIE\s(\d)+(\.(\d)+)+/)[0]
    elsif agent_str.match("Firefox")
      return agent_str.match(/Firefox\/(\d)+(\.(\d)+)+/)[0]
    elsif agent_str.match("Chrome")
      return agent_str.match(/Chrome\/(\d)+(\.(\d)+)+/)[0]
    elsif agent_str.match("Safari")
      return agent_str.match(/Safari\/(\d)+(\.(\d)+)+/)[0]
    else
      return ""
    end 
  end

  def create_comment_special_logic_for(comment)
    if comment.creator.is_admin?
      self.send_email_of_thanks(comment)
    end
  end

  include Comment::MarkableMethods
  include Favorite::FavorableMethods
end