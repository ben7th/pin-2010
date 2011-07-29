class ActivationController < ApplicationController
  def services
    render :layout=>"anonymous",:template=>"index/services"
  end

  def activation
    render :layout=>"anonymous",:template=>"index/activation"
  end

  def do_activation
    ActivationCode.acitvate_user(params[:code],current_user)
    redirect_to "/"
  rescue Exception => ex
    flash[:error] = ex.message
    redirect_to "/activation"
  end

  def apply
    render :layout=>"anonymous",:template=>"index/apply"
  end

  def do_apply
    ActivationApply.create(:email=>params[:email],
      :name=>params[:name],:description=>params[:description],
      :homepage=>params[:homepage]
    )
    redirect_to "/apply"
  end
end