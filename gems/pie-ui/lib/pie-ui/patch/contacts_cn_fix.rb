class Contacts
  class NetEase < Base
    def enter_mail_server
      #get mail server and sid
      enter_mail_url = ENTER_MAIL_URL[@mail_type] % @login
      data, resp, cookies, forward = get(enter_mail_url,@cookies)
      unless forward.match(/(http.*)main.jsp\?sid=(.*)?/)
        raise ConnectionError, self.class.const_get(:PROTOCOL_ERROR)
      end
      @cookies = cookies
      @mail_server = $1
      @sid = $2
    end

  end

end