# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |user|
      # Only for fresh accounts:
      if user.persisted? && user.inactive?
        user.start_trial!
      end
    end
  end
end
