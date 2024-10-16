class DashboardsController < ApplicationController
  before_action :find_user, only: [:edit_user_profile, :update_user_profile]

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
    if current_user.admin?
      # Admin: show the most recent courses in the system
      @registered_courses_with_attempts = Course.order(updated_at: :desc).limit(4).map do |course|
        {
          course: course,
          last_activity: course.updated_at
        }
      end
      # For Admin, we don't have registered_courses like other users, so we set it as an empty array
      @registered_courses = []
    else
      # Non-admin: Collect registered courses (for students) and created courses (for teachers)
      @registered_courses = current_user.registrations.includes(course: :questions).map(&:course).uniq
      @groups = current_user.owned_groups

      # For each registered course, find the most recent attempt or registration date
      @registered_courses_with_attempts = @registered_courses.map do |course|
        last_attempt = current_user.attempts.joins(:question).where(questions: { course_id: course.id }).order(updated_at: :desc).first
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
            last_activity: course.updated_at # Use updated_at instead of created_at to capture recent modifications
          }
        end
        @registered_courses_with_attempts.concat(@created_courses)
      end

      # Sort courses by the last activity (attempt, registration, or creation) in descending order
      @registered_courses_with_attempts.sort_by! { |course_with_attempt| course_with_attempt[:last_activity] }.reverse!

      # Limit the display to the top 4 most recent courses
      @registered_courses_with_attempts = @registered_courses_with_attempts.first(4)
    end

    # Ensure @registered_courses is an array even if no courses are found to avoid nil errors
    @courses = Course.where.not(id: @registered_courses.pluck(:id)).order(:title)
    @attempts = current_user.attempts.includes(:question)
  end

  def manage_users
    # Always initialize @users as an empty array if User.all is nil
    @users = User.all || []

    # Handle sorting logic
    case params[:sort]
    when 'role'
      direction = params[:direction] == 'desc' ? :desc : :asc
      @users = @users.order(role: direction)
    when 'first_name'
      direction = params[:direction] == 'desc' ? :desc : :asc
      @users = @users.order("LOWER(first_name) #{direction}")
    when 'last_name'
      direction = params[:direction] == 'desc' ? :desc : :asc
      @users = @users.order("LOWER(last_name) #{direction}")
    else
      # Default sorting, e.g., by last name and first name (case-insensitive)
      @users = @users.sort_by { |user| [user.last_name.downcase, user.first_name.downcase] }
    end
  end

  def my_groups
    if current_user.admin?
      # Admin can see all groups, ordered by the most recently updated
      @groups = Group.order(updated_at: :desc) 
    else
      # Teachers can only see the groups they created, ordered by the most recently updated
      @groups = current_user.owned_groups.order(updated_at: :desc)
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
