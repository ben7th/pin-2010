class Account::CompleteController < ApplicationController
  def index
    render :layout=>'account'
  end

  def submit
    valid_user = User.new(params[:user])
    valid_user.name = randstr
    unless valid_user.valid?
      flash[:error] = get_flash_error(valid_user)
      return redirect_tsina_signup
    end

    current_user.email = params[:user][:email]
    current_user.password = params[:user][:password]
    current_user.password_confirmation = params[:user][:password_confirmation]

    if current_user.save
      return redirect_root_by_service
    end

    flash[:error] = get_flash_error(current_user)
    redirect_tsina_signup
  end

  private
  def redirect_tsina_signup
    if params[:service] == "tu"
      return redirect_to "/account/tsina_signup?service=tu"
    else
      return redirect_to "/account/tsina_signup"
    end
  end

  def redirect_root_by_service
    if params[:service] == "tu"
      redirect_to(pin_url_for("pin-daotu"))
    else
      redirect_to(root_url)
    end
  end

end