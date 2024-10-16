
class StudentsController < ApplicationController
  before_action :set_student, only: [:show]
  
  def show
    @courses = @student.registrations.includes(:course).map(&:course) 
    @attempts = @student.attempts.includes(:question)
  end
  
  private
  
  def set_student
    @student = User.find(params[:id])
    unless @student.student?
      redirect_to root_path, alert: "This user is not a student."
    end
  end
end
  