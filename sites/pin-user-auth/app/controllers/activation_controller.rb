class ActivationController < ApplicationController

  def apply
    @is_applied = params[:r] == 'success'
    render :layout=>"anonymous", :template=>"index/activation/apply"
  end

  def apply_submit
    ApplyRecord.create(:email=>params[:email],:name=>params[:name],:description=>params[:description])
    redirect_to "/apply?r=success"
  end

  def activation
    return redirect_to '/' if logged_in? && current_user.is_v2_activation_user?
    render :layout=>"anonymous",:template=>"index/activation"
  end

  def activation_submit
    if !current_user.is_v2_activation_user?
      ActivationCode.acitvate_user(params[:code],current_user)
    end
    redirect_to "/"
  rescue Exception => ex
    flash[:error] = ex.message
    redirect_to "/activation"
  end
  
end