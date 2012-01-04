module PieUi

  module PartialHelper
    def render_with_error_msg(err_message, path, params={})
      begin
        render path, params
      rescue Exception => ex
        return "<div class='render-error'>错误：#{ex}</div>"          if Rails.env.development?
        return "<div class='render-error'>错误：#{err_message}</div>" if Rails.env.production?
      end
    end
  end
  
end