# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |user|
      # Only for fresh accounts:
      if user.persisted? && user.inactive?
        user.start_trial!
      end
      
      # Set flash message if user was created but needs approval
      if user.persisted? && !user.approved?
        flash[:notice] = "Je account is succesvol aangemaakt. Je ontvangt een e-mail zodra een beheerder je account heeft goedgekeurd."
      end
    end
  end
end
