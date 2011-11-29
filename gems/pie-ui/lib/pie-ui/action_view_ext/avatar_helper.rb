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

    def logo(model, style=nil)
      alt = get_visable_name(model)
      klass = ['logo', style]*' '

      unless model.blank?
        src   = model.logo.url(style)
        meta  = [dom_id(model), style]*','
        
        "<img src='#{src}' alt='#{alt}' class='#{klass}' data-meta='#{meta}'/>"
      else
        src   = User.new.logo.url(style)
        meta  = ['unknown', style]*','

        "<img src='#{src}' alt='#{alt}' class='#{klass}' data-meta='#{meta}'/>"
      end
    end

    def avatar(user_or_email, style=nil)
      case user_or_email
      when User
        logo(user_or_email,style)
      when String
        logo(User.find_by_email(user_or_email), style)
      else
        logo(nil, style)
      end
    end
    
  end
end
