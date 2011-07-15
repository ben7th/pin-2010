# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ApplicationMethods
  helper :all
  protect_from_forgery

  around_filter :catch_oauth_exception
  def catch_oauth_exception
    yield
  rescue Tsina::OauthFailureError=>tsina_error
    if request.xhr?
      return render :text=>tsina_error.message,:status=>503
    else
      return render_status_page(503,tsina_error.message)
    end
  end


  UN_UPLOADING_PAGE = {
    "sessions"=>["create","destroy"],
    "users"=>["new","create",
      "forgot_password_form","forgot_password",
      "reset_password","change_password"
      ],
    "account"=>["base","base_submit",
      "avatared","avatared_submit",
      "bind_tsina","do_unbind","do_tsina_connect_setting"
    ],
    "connect_users"=>["update_bind_tsina_info",
      "bind_tsina","bind_tsina_callback",
      "bind_tsina_failure"
      ]
  }
  before_filter :redirect_updating_page
  def redirect_updating_page
    controller = params[:controller]
    action = params[:action]

    as = UN_UPLOADING_PAGE[controller]
    if as.nil? || !as.include?(action)
      return to_updating_page
    end
  end

  def to_updating_page
    redirect_to pin_url_for("ui","updating.html")
  end
end