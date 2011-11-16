class CourseItemsController < ApplicationController
  before_filter :per_load
  def per_load
    @course_item = CourseItem.find(params[:id]) if params[:id]
  end

  def index
    @course_items = CourseItem.find(:all,
      :conditions=>{:order_num=>params[:order_num],
        :week_day=>params[:week_day] }).
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
end