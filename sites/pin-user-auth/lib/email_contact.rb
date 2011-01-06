class EmailContact

   require 'contacts_cn'
  def self.fetch_email_contacts(login_add, password, type)

    if(type=="0")
      return raise ContactEmailUsedError,"请选择邮箱类型"
    end

    login = "#{login_add}@#{type}"
    if(!login.match(/^([A-Za-z0-9_]+)([\.\-\+][A-Za-z0-9_]+)*(\@[A-Za-z0-9_]+)([\.\-][A-Za-z0-9_]+)*(\.[A-Za-z0-9_]+)$/))
      return raise ContactEmailUsedError,"邮箱地址格式不正确"
    end

    name_and_emails = case type
    when "hotmail.com"
      Contacts::Hotmail.new(login, password).contacts # => [["name", "foo@bar.com"], ["another name", "bow@wow.com"]]
    when "aol.com"
      Contacts::Aol.new(login, password).contacts
    when "gmail.com"
      Contacts::Gmail.new(login, password).contacts
    when "plaxo.com"
      Contacts::Plaxo.new(login, password).contacts
    when "126.com"
      Contacts::NetEase.new(login,password).contacts
    when "163.com"
      Contacts::NetEase.new(login,password).contacts
    when "yeah.com"
      Contacts::NetEase.new(login,password).contacts
    when "sina.com"
      Contacts::Sina.new(login,password).contacts
    when "sohu.com"
      Contacts::Sohu.new(login, password).contacts
    when "yahoo.com"
      Contacts::Yahoo.new(login, password).contacts
    end

    if name_and_emails.blank?
      return raise ContactEmailUsedError,"邮箱中没有联系人"
    end

    name_and_emails.map do |name_and_email|
      name_and_email[1]
    end
  end

  class ContactEmailUsedError < StandardError;end
end
