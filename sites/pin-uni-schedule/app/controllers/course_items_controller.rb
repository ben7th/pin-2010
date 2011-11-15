class CourseItemsController < ApplicationController
  before_filter :per_load
  def per_load
    @course_item = CourseItem.find(params[:id]) if params[:id]
  end

  def index
    @course_items = CourseItem.find(:all,
      :conditions=>{:order_num=>params[:order_num],:week_day=>params[:week_day] })
  end

  def show
  end

  def select
    current_user.select_course_item(@course_item)
    redirect_to "/course_items?week_day=#{params[:week_day]}&order_num=#{params[:order_num]}"
  end

  def cancel_select
    current_user.cancel_select_course_item(@course_item)
    redirect_to "/course_items?week_day=#{params[:week_day]}&order_num=#{params[:order_num]}"
  end
end