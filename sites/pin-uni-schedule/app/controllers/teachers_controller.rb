class TeachersController < ApplicationController
  before_filter :login_required
  before_filter :per_load
  def per_load
    @teacher = Teacher.find(params[:id]) if params[:id]
  end

  def show
  end

  def edit
  end

  def update
    @teacher.logo = params[:logo]
    @teacher.save
    redirect_to "/teachers/#{@teacher.id}/edit"
  end
end