class GroupsController < ApplicationController
  before_action :set_group, only: [:edit, :update, :destroy]

  def create
    @group = current_user.owned_groups.new(group_params)
    
    # Check if the current user is admin; set teacher explicitly for consistency
    @group.teacher = current_user if current_user.admin?
    
    # If groups were selected in the "Select all students from an existing group" dropdown
    if params[:group_ids].present?
      selected_groups = Group.where(id: params[:group_ids])
      selected_students = selected_groups.flat_map(&:students).uniq # Get all students from the selected groups
      
      # Filter out students who are already manually selected in the checkboxes
      manually_selected_students = User.where(id: params[:group][:student_ids])
      remaining_students = selected_students - manually_selected_students
      
      @group.students += remaining_students # Add only non-duplicated students to the new group
    end
    
    if @group.save
      ActivityLogger.log_group_created(user: current_user, group: @group)
      redirect_to dashboard_my_groups_path, notice: "Group created successfully!"
    else
      flash.now[:alert] = @group.errors.full_messages.join(", ")
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash-messages", partial: "shared/flashes") }
        format.html { render :new }
      end
    end
  end  
  
  def destroy
    # Clear associations with students and courses before deleting the group
    @group.students.clear
    @group.courses.clear
    
    if @group.destroy
      ActivityLogger.log_group_deleted(user: current_user, group_name: @group.name)
      flash[:notice] = "Group deleted successfully."
      redirect_to request.referer || dashboard_my_groups_path
    else
      flash[:alert] = "There was an issue deleting the group."
      redirect_to request.referer || dashboard_my_groups_path
    end
  end
  
  def edit
    @group = Group.find(params[:id])
    @groups = Group.all
    
    # Ensure only authorized users can edit the group
    unless current_user.teacher? || current_user.admin?
      redirect_to dashboard_my_groups_path, alert: "You are not authorized to edit this group."
    end
  end
  
  def new
    @group = Group.new
    @groups = Group.all
  end

  def update
    @group = Group.find(params[:id])
    
    # Clear existing students if the teacher deselects them all
    @group.students.clear
  
    # If groups were selected in the "Select all students from an existing group" dropdown
    if params[:group_ids].present?
      selected_groups = Group.where(id: params[:group_ids])
      selected_students = selected_groups.flat_map(&:students).uniq # Get all students from the selected groups
      manually_selected_students = User.where(id: params[:group][:student_ids])
      remaining_students = selected_students - manually_selected_students
  
      @group.students += remaining_students # Add only non-duplicated students to the group
    end
  
    # Update the group name and manually selected students
    if @group.update(group_params)
      @group.touch # Explicitly update the `updated_at` field to reflect this update
      ActivityLogger.log_group_updated(user: current_user, group: @group)
      redirect_to dashboard_my_groups_path, notice: "Group updated successfully!"
    else
      flash.now[:alert] = @group.errors.full_messages.join(", ")
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash-messages", partial: "shared/flashes") }
        format.html { render :edit }
      end
    end
  end  

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name, student_ids: [])
  end
end
