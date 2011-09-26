# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include ApplicationMethods
  helper :all
  protect_from_forgery

  #--------------------------------------------------

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


  UN_UPDATING_PAGE = {
    "index"=>["index"],
    "sessions"=>["new","create","destroy"],
    "users"=>["new","create",
      "forgot_password_form","forgot_password",
      "reset_password","change_password","show"
      ],
    "account"=>["base","base_submit",
      "avatared","avatared_submit",
      "bind_tsina","do_tsina_connect_setting"
    ],
    "connect_tsina"=>[
      "index","callback","confirm",
      "complete_account_info","do_complete_account_info",
      "bind","create",
      "account_bind","account_bind_callback",
      "account_bind_failure","account_bind_update_info",
      "account_bind_unbind"
    ],
    "contacts"=>["follow","unfollow",
      "followings","fans","create"
    ],
    "activation"=>["services",
      "apply","do_apply",
      "apply_form","do_apply_form",
      "activation","do_activation"
      ],
    "feeds"=>["show"]
  }
  before_filter :redirect_services_page
  def redirect_services_page
    controller = params[:controller]
    action = params[:action]

    as = UN_UPDATING_PAGE[controller]
    return true if !!as && as.include?(action) #指定action，放行PASS

    if logged_in?
      if current_user.is_v2_activation_user?
        return true #放行PASS
      end
      return redirect_to "/services"
    end

    redirect_to "/"
  end

  def to_updating_page
    redirect_to pin_url_for("ui","updating.html")
  end


end