class StudentsController < ApplicationController
  before_action :set_student, only: [:show]

  def index
    unless current_user.admin? || current_user.teacher?
      redirect_to root_path, alert: "Je bent niet gemachtigd om deze pagina te bekijken."
      return
    end

    @students = User.where(role: "student")
  end

  def show
    unless current_user.admin? || current_user.teacher?
      redirect_to root_path, alert: "Je bent niet gemachtigd om deze pagina te bekijken."
      return
    end

    @registrations = @student.registrations.includes(:course).order(created_at: :desc)
    @courses = @registrations.map(&:course)
    @attempts = @student.attempts.includes(:question)
  end

  private

  def set_student
    @student = User.find(params[:id])
    unless @student.student?
      redirect_to root_path, alert: "Deze gebruiker is geen student"
    end
  end
end
