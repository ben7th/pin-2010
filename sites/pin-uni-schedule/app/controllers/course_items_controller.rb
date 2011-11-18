class CourseItemsController < ApplicationController
  before_filter :per_load
  def per_load
    @course_item = CourseItem.find(params[:id]) if params[:id]
  end

  def index
    @course_items = current_user.can_select_course_item_list(params[:week_day],
      params[:order_num]).
    paginate(:per_page=>20,:page=>params[:page]||1)
  end

  def show
  end

  def select
    current_user.select_course_item(@course_item)
    render :partial=>'/course_items/parts/list',:locals=>{:course_items=>[@course_item]}
  end

  def cancel_select
    current_user.cancel_select_course_item(@course_item)
    render :partial=>'/course_items/parts/list',:locals=>{:course_items=>[@course_item]}
  end
  
  def new
    @university = current_user.profile.university
  end
  
  def create
    university = current_user.profile.university
    # department
    if params[:department_id].to_i == -1
      department = Department.create_or_find(university,params[:department_name])
    else
      department = Department.find(params[:department_id])
    end
    # course
    if params[:course_id].to_i == -1
      course = Course.create_or_find(university,department,params[:course_name],params[:course_cid])
    else
      course = Course.find(params[:course_id])
    end
    # teacher
    if params[:teacher_id].to_i == -1
      teacher = Teacher.create_or_find(university,params[:teacher_name],params[:teacher_tid])
    else
      teacher = Teacher.find(params[:teacher_id])
    end
    # location
    if params[:location_id].to_i == -1
      location = Location.create_or_find(university,params[:location_name])
    else
      location = Location.find(params[:location_id])
    end
    # course_item
    CourseItem.create(
      :week_day=>params[:week_day],
      :order_num=>params[:order_num],
      :period=>params[:period],
      :location=>location,
      :teacher=>teacher,
      :course=>course
    )
    redirect_to "/course_items?week_day=#{params[:week_day]}&order_num=#{params[:order_num]}"
  end

end