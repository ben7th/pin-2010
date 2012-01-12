class Mailer < ActionMailer::Base
  default :from => "MINDPIN社区 <noreply@mindpin.com>"
  # 发送密码重设
  def forgotpassword(user)
    @user = user
    mail(:to => user.email, :subject => "来自MINDPIN的密码重置邮件")
  end

  def apply_confirm(email, name, code)
    @name = name
    @code = code
    mail(:to => email, :subject => "MINDPIN社区内测邀请激活码")
  end
end
