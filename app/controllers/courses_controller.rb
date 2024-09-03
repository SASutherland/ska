class CoursesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_teacher, only: [:new, :create]

  def new
    @course = Course.new
  end

  def create
    @course = current_user.courses.build(course_params)
    if @course.save
      flash[:notice] = "Course created successfully!"
      redirect_to dashboards_index_path
    else
      flash[:alert] = "There was an issue creating the course."
      render :new
    end
  end

  def index
    @registered_courses = current_user.registrations.includes(course: :questions).map(&:course)
  end

  def unenroll
    course = Course.find(params[:id])
    registration = current_user.registrations.find_by(course: course)

    if registration
      registration.destroy
      flash[:notice] = "You have successfully unenrolled from #{course.title}."
    else
      flash[:alert] = "You are not enrolled in this course."
    end

    redirect_to courses_path
  end

  private

  def course_params
    params.require(:course).permit(:title, :description, questions_attributes: [
      :content, :question_type, answers_attributes: [:content, :correct]
    ])
  end

  def authorize_teacher
    redirect_to root_path, alert: "You are not authorized to perform this action." unless current_user.teacher?
  end
end
