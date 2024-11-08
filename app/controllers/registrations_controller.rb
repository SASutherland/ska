class RegistrationsController < ApplicationController
  before_action :authenticate_user!

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
end
