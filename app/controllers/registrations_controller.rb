class RegistrationsController < ApplicationController
  before_action :authenticate_user!
  include EnsuresCourseAccess
  trial_mode :start

  def create
    @registration = current_user.registrations.build(registration_params)

    if @registration.save
      Trial::UsageRecorder.new(current_user).record_course_started!(@registration.course)
      ActivityLogger.log_registration_created(user: current_user, registration: @registration)
      redirect_to @registration.course, notice: "Succes! De cursus is gestart."
    else
      redirect_back fallback_location: courses_path, alert: @registration.errors.full_messages.to_sentence
    end
  end

  def update_time_spent
    registration = Registration.find_by(user_id: current_user.id, course_id: params[:course_id])
    if registration
      registration.time_spent = params[:time_spent]
      if registration.save
        render json: {success: true}, status: :ok
      else
        render json: {success: false, errors: registration.errors.full_messages}, status: :unprocessable_entity
      end
    else
      render json: {success: false, error: "Registratie niet gevonden"}, status: :not_found
    end
  end

  private

  def registration_params
    params.require(:registration).permit(:course_id)
  end

end
