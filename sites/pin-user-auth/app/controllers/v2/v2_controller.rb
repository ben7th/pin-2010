class V2::V2Controller < ApplicationController
  before_filter :activation_user_required,:except=>[:do_activate]
  before_filter :layout_v2

  def activation_user_required
    return login_required if current_user.blank?

    unless ActivationCode.is_v2_activation_user?(current_user)
      return render :template=>"v2/index/activation"
    end
  end

  def layout_v2
    render :layout=>'v2/layouts/v2'
  end

end
