class EmailContact
  require 'contacts_cn'
  def initialize(login_address, password, type,current_user)
    @login_address = login_address
    @password = password
    @type = type
    @login = "#{@login_address}@#{@type}"
    @current_user = current_user
    _check_type
    _check_login_address
  end

  def get_name_and_emails
    case @type
    when "hotmail.com"
      Contacts::Hotmail.new(@login, @password).contacts # => [["name", "foo@bar.com"], ["another name", "bow@wow.com"]]
    when "aol.com"
      Contacts::Aol.new(@login, @password).contacts
    when "gmail.com"
      Contacts::Gmail.new(@login, @password).contacts
    when "plaxo.com"
      Contacts::Plaxo.new(@login, @password).contacts
    when "126.com"
      Contacts::NetEase.new(@login,@password).contacts
    when "163.com"
      Contacts::NetEase.new(@login,@password).contacts
    when "yeah.com"
      Contacts::NetEase.new(@login,@password).contacts
    when "sina.com"
      Contacts::Sina.new(@login,@password).contacts
    when "sohu.com"
      Contacts::Sohu.new(@login, @password).contacts
    when "yahoo.com"
      Contacts::Yahoo.new(@login, @password).contacts
    end
  end

  def self.fetch_email_contacts(login_address, password, type, current_user)
    EmailContact.new(login_address, password, type, current_user).get_result
  end

  def get_result
    results = get_name_and_emails
    raise ContactEmailNoneError,"邮箱中没有联系人" if results.blank?

    email_actors = []
    # 只取返回结果中的email，并构建 email_actor
    results.each do |name_and_email|
      email = name_and_email[1]
      if(email != @current_user.email)
        email_actors << EmailActor.new(email)
      end
    end
    result_to_hash(email_actors)
  end

  def result_to_hash(email_actors)
    re = {
      :already_contact_email_actors              => [],
      :not_contacts_already_regeist_email_actors => [],
      :not_contact_not_regeist_email_actors      => []
    }

    email_actors.each do |actor|
      if actor.signed_in?
        if current_user_has_contacted?(actor)
          re[:already_contact_email_actors] << actor
        else
          re[:not_contacts_already_regeist_email_actors] << actor
        end
      else
        # 没有注册的邮件地址
        re[:not_contact_not_regeist_email_actors] << actor
      end
    end

    return re
  end

  def current_user_has_contacted?(actor)
    @current_user.get_contact_obj_of(actor.actor)
  end

  class ContactEmailTypeError < StandardError;end
  class ContactEmailNoneError < StandardError;end


  private
  def _check_type
    if(@type=="0")
      raise ContactEmailTypeError,"请选择邮箱类型"
    end
  end

  def _check_login_address
    EmailActor.new(@login)
  end
end
