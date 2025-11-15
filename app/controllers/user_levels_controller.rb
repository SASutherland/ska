class UserLevelsController < ApplicationController
  before_action :authenticate_user!

  def create
    level_number = params[:level_number].to_i
    
    # Find the level by extracting the number from the level name
    level = Level.all.find do |l|
      level_number_from_name = l.name.scan(/\d+/).first&.to_i
      level_number_from_name == level_number
    end

    if level
      # Remove all existing user levels first
      current_user.user_levels.destroy_all
      
      # Create the new user level
      UserLevel.find_or_create_by(user: current_user, level: level)
      redirect_to dashboard_path, notice: "Je groep is succesvol ingesteld."
    else
      redirect_to dashboard_path, alert: "Er is een probleem opgetreden bij het instellen van je groep."
    end
  end

  def destroy
    current_user.user_levels.destroy_all
    redirect_to dashboard_path, notice: "Je groep is verwijderd. Je kunt nu een nieuwe groep kiezen."
  end
end

