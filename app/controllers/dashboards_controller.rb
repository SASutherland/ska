class DashboardsController < ApplicationController
  def index
    @registered_courses = current_user.registrations.includes(course: :questions).map(&:course).uniq
    @groups = current_user.owned_groups

    # For each course, find the most recent attempt or registration date
    @registered_courses_with_attempts = @registered_courses.map do |course|
      last_attempt = current_user.attempts.joins(:question).where(questions: {course_id: course.id}).order(updated_at: :desc).first
      last_registration = current_user.registrations.find_by(course_id: course.id)

      {
        course: course,
        last_activity: last_attempt ? last_attempt.updated_at : last_registration.created_at
      }
    end

    # Include created courses for teachers
    if current_user.teacher?
      @created_courses = current_user.courses.map do |course|
        {
          course: course,
          last_activity: course.created_at
        }
      end
      @registered_courses_with_attempts.concat(@created_courses)
    end

    # Sort courses by the last activity (attempt, registration, or creation) in descending order
    @registered_courses_with_attempts.sort_by! { |course_with_attempt| course_with_attempt[:last_activity] }.reverse!

    # Limit the display to the top 4 most recent courses
    @registered_courses_with_attempts = @registered_courses_with_attempts.first(4)

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

  def my_groups
    @groups = current_user.owned_groups
  end
end
