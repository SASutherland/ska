class LevelsController < ApplicationController

  def index
    @levels = Level.all
  end

  def edit
    @level = Level.find(params[:id])
    @courses = Course.all

    # Ensure only authorized users can edit the level
    unless current_user.teacher? || current_user.admin?
      redirect_to dashboard_path, alert: "You are not authorized to edit this level."
    end
  end

  def update
    @level = Level.find(params[:id])
    if @level.update(level_params)
      redirect_to dashboard_levels_path, notice: "Level updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def new
    @level = Level.new
  end

  def create
    @level = Level.new(level_params)
    if @level.save
      redirect_to levels_path, notice: "Level created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def level_params
    params.require(:level).permit(:name)
  end
end