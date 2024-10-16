class CoursesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_teacher, only: [:new, :create, :edit, :update, :destroy, :my_courses]
  before_action :set_course, only: [:edit, :update, :destroy]

  def create
    @course = current_user.courses.build(course_params)
    
    if @course.save
      # Handle true/false and open-answer questions
      handle_true_false_questions(@course)
      handle_open_answer_questions(@course)
  
      # Automatically register the current user (teacher) for the course
      current_user.registrations.create(course: @course)
  
      # Register all students from selected groups for the new course
      if params[:group_ids].present?
        selected_groups = Group.where(id: params[:group_ids])
        selected_students = selected_groups.flat_map(&:students).uniq # Get all unique students from the selected groups
  
        selected_students.each do |student|
          # Register the student for the course
          Registration.find_or_create_by(user: student, course: @course)
        end
      end
  
      flash[:notice] = "Course created and students have been enrolled!"
      redirect_to dashboard_path
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = "Make sure to add a course title and fill in all question fields."
          render turbo_stream: turbo_stream.replace("flash-messages", partial: "shared/flashes")
        end
        format.html do
          flash.now[:alert] = "There was an issue creating the course."
          render :new, status: :unprocessable_entity
        end
      end
    end
  end  

  def destroy
    @course.questions.each do |question|
      # Destroy attempts associated with the question's answers first
      question.answers.each do |answer|
        answer.attempts.destroy_all
      end
      question.attempts.destroy_all
    end

    if @course.destroy
      flash[:notice] = "Course deleted successfully."
      redirect_to request.referer || my_courses_courses_path
    else
      flash[:alert] = "There was an issue deleting the course."
      redirect_to request.referer || my_courses_courses_path
    end
  end

  def edit
    # @course is already set by set_course
    @groups = current_user.owned_groups
  end

  def index
    @registered_courses = current_user.registrations.includes(course: :questions).map(&:course).sort_by(&:title)
    @attempts = current_user.attempts.includes(:question)
  end

  def my_courses
    @created_courses = current_user.courses.order(:title)
  end

  def new
    @course = Course.new
    @groups = current_user.owned_groups
  end

  def submit_answer
    question = Question.find(params[:id])

    if question.question_type == "open_answer"
      handle_open_answer_submission(question)
    else
      chosen_answer = question.answers.find(params[:answer])
      attempt = current_user.attempts.find_or_initialize_by(question: question)
      attempt.update(chosen_answer: chosen_answer, correct: chosen_answer.correct?)
    end

    redirect_to course_question_path(question.course, question.next_question)
  end

  def update
    if @course.update(course_params)
      #   If a course is edited, it is done so through the new course form, and
      #   the new course is saved as a new, distinct course.
      #
      handle_multiple_answer_questions(@course)
      handle_open_answer_questions(@course)
      handle_true_false_questions(@course)
      flash[:notice] = "Course updated successfully!"
      redirect_to my_courses_courses_path
    else
      flash[:alert] = "There was an issue updating the course."
      render :edit
    end
  end

  def unenroll
    course = Course.find(params[:id])
    registration = current_user.registrations.find_by(course: course)

    if registration
      registration.destroy
      flash[:notice] = "You have successfully unenrolled from #{course.title}."
    else
      flash[:alert] = "You are not enrolled in this course."
    end

    redirect_to courses_path
  end

  private

  def authorize_teacher
    redirect_to root_path, alert: "You are not authorized to perform this action." unless current_user.teacher?
  end

  def course_params
    params.require(:course).permit(
      :title,
      :description,
      group_ids: [],
      questions_attributes: [
        :id,
        :content,
        :question_type,
        :image,
        :_destroy,
        answers_attributes: [
          :id,
          :content,
          :correct,
          :_destroy
        ]
      ]
    )
  end

  def handle_multiple_answer_questions(course)
    course.questions.each do |question|
      if question.question_type == "multiple_answer"
        # For each answer, if `correct` is not set, set it to `false`
        question.answers.each do |answer|
          answer.update(correct: false) if answer.correct.nil?
        end
      end
    end
  end

  def handle_open_answer_questions(course)
    course.questions.each do |question|
      if question.question_type == "open_answer"
        # Find the question attributes in the params and ensure it's present
        question_params = params[:course][:questions_attributes].values.find { |q| q["content"] == question.content }

        if question_params && question_params["answers_attributes"]
          # Find the correct answer in the answers_attributes (could be any index)
          correct_answer_params = question_params["answers_attributes"].values.find { |answer| answer["content"].present? }

          if correct_answer_params
            correct_answer_content = correct_answer_params["content"]

            # Create or update the answer if necessary
            question.answers.create!(content: correct_answer_content, correct: true) if question.answers.empty?
          else
            flash[:alert] = "No correct answer provided for the open-answer question '#{question.content}'."
          end
        else
          flash[:alert] = "No answer parameters provided for the question '#{question.content}'."
        end
      end
    end
  end

  def handle_open_answer_submission(question)
    user_answer_content = params[:answer_content]

    # Find or initialize an attempt for this question
    attempt = current_user.attempts.find_or_initialize_by(question: question)

    # Find or create the user's answer based on input
    user_answer = question.answers.find_or_initialize_by(content: user_answer_content)
    user_answer.save if user_answer.new_record?

    # Find the correct answer
    correct_answer = question.answers.find_by(correct: true)

    # Check if the correct answer exists
    if correct_answer.present?
      # Check if the user's answer matches the correct answer
      is_correct = user_answer_content.strip.downcase == correct_answer.content.strip.downcase

      # Update the attempt with the user's written answer and correctness
      attempt.update(written_answer: user_answer_content, correct: is_correct)
    else
      flash[:alert] = "Correct answer not found for this question."
      redirect_to course_question_path(question.course, question)
    end
  end

  def handle_true_false_questions(course)
    course.questions.each do |question|
      if question.question_type == "true_false"
        unless question.answers.exists?(content: "True") && question.answers.exists?(content: "False")
          question.answers.create!(content: "True", correct: true) unless question.answers.exists?(content: "True")
          question.answers.create!(content: "False", correct: false) unless question.answers.exists?(content: "False")
        end
      end
    end
  end

  def set_course
    @course = Course.find(params[:id])
  end
end
