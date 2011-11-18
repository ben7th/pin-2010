class ProfilesController < ApplicationController
  before_filter :login_required

  def new
    @universities = University.all
  end

  def create
    current_user.set_university _create_find_university
    redirect_to "/"
  end

  def _create_find_university
    if params[:university_id].to_i == -1
      name = params[:university_name].strip
      university = University.find_or_create_by_name(name)
    else
      university = University.find(params[:university_id])
    end
    university
  end
end