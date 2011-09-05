module PieUi
  module AvatarHelper

    def get_visable_name(model)
      return t("NULLDATA") if model.blank?
      begin
        model.name
      rescue NoMethodError
        model.title
      end
    end

    def logo(model, style=nil, id=nil)
      style_str = style.nil? ? '':"_#{style}"
      alt = get_visable_name(model)

      unless model.blank?
        id = "#{dom_id(model)}#{style_str}"
        logo_url = model.logo.url(style)
        src = model.logo_file_name.blank? ? pin_url_for('pin-user-auth',logo_url) : logo_url
        "<img alt='#{alt}' class='logo #{style}' id='logo_#{id}' src='#{src}'/>"
      else
        src = pin_url_for('pin-user-auth',"/images/logo/default_unknown_#{style}.png")
        "<img alt='#{alt}' class='logo #{style}' src='#{src}'/>"
      end
    end

    def avatar(user_or_email, style=nil)
      case user_or_email
      when User
        logo(user_or_email,style)
      when String
        avatar_by_email(user_or_email,style)
      else
        src = pin_url_for('ui',"/images/logo/default_unknown_#{style}.png")
        "<img alt='guest' class='logo guest #{style}' src='#{src}'/>"
      end
    end

    def avatar_by_email(email, style)
      user = User.find_by_email(email)
      logo(user,style)
    end
  end
end
