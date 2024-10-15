class GroupsController < ApplicationController
  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    @group.teacher = current_user 
  
    if @group.save
      # Assign students to the group, ensuring no duplicates
      student_ids = params[:group][:student_ids]
      if student_ids.present?
        students_to_add = User.where(id: student_ids) - @group.students
        @group.students << students_to_add unless students_to_add.empty?
      end
  
      # Use respond_to to handle both HTML and Turbo requests
      respond_to do |format|
        format.html { redirect_to dashboard_my_groups_path, notice: 'Group was successfully created.' }
        format.turbo_stream { redirect_to dashboard_my_groups_path, notice: 'Group was successfully created.' }
      end
    else
      flash[:alert] = 'Error creating group.'
      render :new, status: :unprocessable_entity
    end
  end
  

  private

  def group_params
    params.require(:group).permit(:name, student_ids: [])
  end
end
