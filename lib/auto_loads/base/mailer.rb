class Mailer < ActionMailer::Base

  def _init
    @from = 'MINDPIN社区<noreply@mindpin.com>'
    @sent_on = Time.now
    @content_type = "text/html"
  end
  
  # 发送密码重设
  def forgotpassword(user)
    _init
    @recipients = user.email
    @body = {'user'=>user}
    @subject = "来自MINDPIN的密码重置邮件"
  end
  
  def apply_confirm(email, name, code)
    _init
    @recipients = email
    @body = {'name'=>name, 'code'=>code}
    @subject = "MINDPIN社区内测邀请激活码"
  end
end
