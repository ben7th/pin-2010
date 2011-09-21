module PieUi
  module LinkHelper

    def usersign(user, sign=false, length=24)
      re = []
      if user.blank?
        re << '未知用户'
      else
        re << "#{link_to user.name,user,:class=>'u-name'}"
        if !user.sign.blank? && sign
          re << "<span class='quiet u-sign'>，#{h truncate_u(user.sign,length)}</span>"
        end
      end
      return re*''
    end

    def usersign_only(user,length=24)
      re = []
      if !user.blank? && !user.sign.blank?
        re << "<span class='quiet u-sign'>#{h truncate_u(user.sign,length)}</span>"
      end
      return re*''
    end

  end
end