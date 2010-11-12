class Mailer

  def self.deliver_welcome_to_workspace(workspace,message,email)
    p "给#{email}发了欢迎邮件"
  end

  def self.deliver_invite_to_workspace(workspace,message,email)
    p "给#{email}发了邀请邮件"
  end
  
end