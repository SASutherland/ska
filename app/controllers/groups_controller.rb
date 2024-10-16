class GroupsController < ApplicationController
  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    @group.teacher = current_user

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
