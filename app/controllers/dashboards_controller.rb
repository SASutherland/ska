class DashboardsController < ApplicationController
  before_action :find_user, only: [:edit_user_profile, :update_user_profile]
  before_action :authorize_admin, only: [:manage_users, :destroy_user, :edit_user_profile, :update_user_profile]

  def destroy_user
    @user = User.find(params[:id])

    if @user.destroy
      redirect_to dashboard_manage_users_path, notice: "Gebruiker is succesvol verwijderd."
    else
      redirect_to dashboard_manage_users_path, alert: "Er was een probleem bij het verwijderen van de gebruiker."
    end
  end

  def edit_user_profile
    # Load user via the :id param
    # @user is already loaded by before_action :find_user
  end

  def index
    # Handle logic differently for Admins, Teachers, and Students
    if current_user.admin?
      # Admin Logic: Show recent courses and weekly tasks across the entire system
      @registered_courses_with_attempts = Course.where(weekly_task: false)
        .order(updated_at: :desc)
        .limit(4)
        .map do |course|
        {
          course: course,
          last_activity: course.updated_at
        }
      end

      # Get the most recent weekly tasks for Admin
      @weekly_tasks = Course.where(weekly_task: true)
        .where("created_at >= ?", 7.days.ago)
        .order(created_at: :desc)

    else
      # Common logic for Teachers and Students
      @registered_courses = current_user.registrations.includes(course: :questions)
        .map(&:course)
        .uniq
      @groups = current_user.owned_groups

      # Collect registered courses (excluding weekly tasks)
      @registered_courses_with_attempts = @registered_courses
        .select { |course| !course.weekly_task }
        .map do |course|
        last_attempt = current_user.attempts.joins(:question)
          .where(questions: {course_id: course.id})
          .order(updated_at: :desc).first
        last_registration = current_user.registrations.find_by(course_id: course.id)

        {
          course: course,
          last_activity: last_attempt ? last_attempt.updated_at : last_registration.created_at
        }
      end

      # If Teacher, include courses they've created
      if current_user.teacher?
        @created_courses = current_user.courses.where(weekly_task: false)
          .map do |course|
          {
            course: course,
            last_activity: course.updated_at # Use updated_at for recent modifications
          }
        end
        @registered_courses_with_attempts.concat(@created_courses)

        # Get all weekly tasks created by the teacher that are still active
        @weekly_tasks = current_user.courses.where(weekly_task: true)
          .where("created_at >= ?", 7.days.ago)
          .order(created_at: :desc)

      else
        # For Students: Load weekly tasks assigned to them
        @weekly_tasks = @registered_courses.select { |course| course.weekly_task && course.created_at >= 7.days.ago }
      end

      # Sort by last activity (descending order)
      @registered_courses_with_attempts.sort_by! { |course_with_attempt| course_with_attempt[:last_activity] }.reverse!

      # Limit the list to the top 4 most recent courses
      @registered_courses_with_attempts = @registered_courses_with_attempts.first(4)
    end

    # Load attempts data for students
    @attempts = current_user.attempts.includes(:question)
  end

  def manage_users
    # Always initialize @users as an empty array if User.all is nil
    @users = User.all || []

    # Handle sorting logic
    case params[:sort]
    when "role"
      direction = (params[:direction] == "desc") ? :desc : :asc
      @users = @users.order(role: direction)
    when "first_name"
      direction = (params[:direction] == "desc") ? :desc : :asc
      @users = @users.order("LOWER(first_name) #{direction}")
    when "last_name"
      direction = (params[:direction] == "desc") ? :desc : :asc
      @users = @users.order("LOWER(last_name) #{direction}")
    else
      # Default sorting, e.g., by last name and first name (case-insensitive)
      @users = @users.sort_by { |user| [user.last_name.downcase, user.first_name.downcase] }
    end
  end

  def my_groups
    unless current_user.admin? || current_user.teacher?
      redirect_to root_path, alert: "Je bent niet gemachtigd om deze pagina te bekijken."
      return
    end

    @groups = if current_user.admin?
      # Admin can see all groups, ordered by the most recently updated
      Group.order(updated_at: :desc)
    else
      # Teachers can only see the groups they created, ordered by the most recently updated
      current_user.owned_groups.order(updated_at: :desc)
    end
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

  def update_user_profile
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to dashboard_manage_users_path, notice: "Gebruiker is succesvol bijgewerkt."
    else
      flash.now[:alert] = "Er was een probleem bij het bijwerken van de gebruiker."
      render :edit_user_profile
    end
  end

  private

  def authorize_admin
    redirect_to root_path, alert: "You are not authorized to perform this action." unless current_user.admin?
  end

  def find_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :role)
  end
end
