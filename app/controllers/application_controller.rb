class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!, except: [:home]

  def after_sign_in_path_for(resource)
    dashboard_path
  end

  def after_update_path_for(resource)
    dashboard_path
  end

  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :role,
      :first_name,
      :last_name
      ]
    )

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :role,
      :first_name,
      :last_name
      ]
    )
  end

end
