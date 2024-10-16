class GroupsController < ApplicationController
  def new
    @group = Group.new
    @groups = Group.all
  end

  def create
    @group = current_user.owned_groups.new(group_params)

    # If groups were selected in the "Select all students from an existing group" dropdown
    if params[:group_ids].present?
      selected_groups = Group.where(id: params[:group_ids])
      selected_students = selected_groups.flat_map(&:students).uniq # Get all students from the selected groups
      @group.students += selected_students # Add them to the new group
    end

    if @group.save
      redirect_to dashboard_my_groups_path, notice: "Group created successfully!"
    else
      flash.now[:alert] = @group.errors.full_messages.join(", ")
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash-messages", partial: "shared/flashes") }
        format.html { render :new }
      end
    end
  end

  private

  def group_params
    params.require(:group).permit(:name, student_ids: [])
  end
end
