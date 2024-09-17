class DashboardsController < ApplicationController
  def index
    @registered_courses = current_user.registrations.includes(course: :questions).map(&:course)
    @courses = Course.where.not(id: @registered_courses.pluck(:id)).order(:title)
    @attempts = current_user.attempts.includes(:question)
  end

  def register_for_course
    course = Course.find(params[:selected_course_id])
    if current_user.registrations.exists?(course: course)
      redirect_to dashboard_path, alert: "You are already registered for #{course.title}."
    else
      current_user.registrations.create(course: course)
      redirect_to dashboard_path, notice: "You have successfully registered for #{course.title}."
    end
  end
end
