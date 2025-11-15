class DashboardsController < ApplicationController
  before_action :find_user, only: [:edit_user_profile, :update_user_profile, :approve_user]
  before_action :authorize_admin, only: [:manage_users, :destroy_user, :edit_user_profile, :update_user_profile, :approve_user, :logbook]

  def destroy_user
    @user = User.not_deleted.find(params[:id])
    user_snapshot = { id: @user.id, email: @user.read_attribute(:email), name: @user.full_name }

    if @user.destroy
      ActivityLogger.log_user_deleted(actor: current_user, user_snapshot: user_snapshot)
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
        .includes(:questions, active_registrations: :user)
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
          .includes(:questions, active_registrations: :user)
          .order(created_at: :desc)

      else
        # For Students: Load weekly tasks assigned to them
        @weekly_tasks = @registered_courses.select { |course| course.weekly_task && course.created_at >= 7.days.ago }

        # Find courses matching students's levels
        user_level_ids = current_user.levels.pluck(:id)
        if user_level_ids.any?
          @level_courses = Course.where(weekly_task: false)
            .joins(:course_levels)
            .where(course_levels: { level_id: user_level_ids })
            .distinct
        
          # Exclude courses user is already registered for 
          registered_course_ids = current_user.registrations.pluck(:course_id)
          @level_courses = @level_courses.where.not(id: registered_course_ids) if registered_course_ids.any?
          
          @level_courses = @level_courses.order(updated_at: :desc)
        end
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
    # Always initialize @users as an empty array if User.not_deleted is nil
    @users = User.not_deleted || []

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

  def logbook
    @activity_logs = ActivityLog.includes(:user).recent.limit(200)
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

  def approve_user
    @user = User.not_deleted.find(params[:id])
    unless @user.approved?
      if @user.update(approved: true)
        ActivityLogger.log_user_approved(actor: current_user, user: @user)
        redirect_to dashboard_manage_users_path, notice: "Gebruiker #{@user.full_name} is goedgekeurd."
      else
        redirect_to dashboard_manage_users_path, alert: "Er was een probleem bij het goedkeuren van de gebruiker."
      end
    else
      redirect_to dashboard_manage_users_path, notice: "Gebruiker is al goedgekeurd."
    end
  end

  def update_user_profile
    @user = User.not_deleted.find(params[:id])
    was_approved = @user.approved?
    if @user.update(user_params)
      ActivityLogger.log_user_updated(actor: current_user, user: @user)
      # Log approval if it changed
      if !was_approved && @user.approved?
        ActivityLogger.log_user_approved(actor: current_user, user: @user)
      end
      redirect_to dashboard_manage_users_path, notice: "Gebruiker is succesvol bijgewerkt."
    else
      flash.now[:alert] = "Er was een probleem bij het bijwerken van de gebruiker."
      render :edit_user_profile
    end
  end

  def subscriptions
    @current_subscription = current_user.active_subscription
    @memberships = Membership.all
    @payments = current_user.payments.order(paid_at: :desc)
  end

  private

  def authorize_admin
    redirect_to root_path, alert: "You are not authorized to perform this action." unless current_user.admin?
  end

  def find_user
    @user = User.not_deleted.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :role, :approved)
  end
end
