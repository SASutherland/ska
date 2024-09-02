class DashboardsController < ApplicationController
  def index
    @courses = Course.all
    @registered_courses = current_user.courses.includes(:questions)
  end

  def register_for_course
    course = Course.find(params[:selected_course_id])
    if current_user.courses.include?(course)
      redirect_to dashboards_index_path, alert: "You are already registered for #{course.title}."
    else
      current_user.courses << course
      redirect_to dashboards_index_path, notice: "You have successfully registered for #{course.title}."
    end
  end
end
