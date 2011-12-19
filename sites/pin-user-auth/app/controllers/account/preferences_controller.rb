class Account::PreferencesController < ApplicationController
  before_filter :login_required
  layout 'account'

  def head_cover
  end

  def head_cover_submit
    current_user.set_head_cover(params[:file])
    redirect_to :action=>:head_cover
  end
end