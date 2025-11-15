# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |user|
      # Only for fresh accounts:
      if user.persisted? && user.inactive?
        user.start_trial!
      end

      # Link user to level if group_number is provided
      if user.persisted? && params[:group_number].present?
        group_number = params[:group_number].to_i
        level = Level.all.find do |l|
          # Extract integer from level name (e.g., "Leerlingenlijst 3" -> 3)
          level_number = l.name.scan(/\d+/).first&.to_i
          level_number == group_number
        end
        if level
          UserLevel.find_or_create_by(user: user, level: level)
        end
      end
    end
  end
end
