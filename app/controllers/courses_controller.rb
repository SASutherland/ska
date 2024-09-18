class CoursesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_teacher, only: [:new, :create, :edit, :update, :destroy, :my_courses]
  before_action :set_course, only: [:edit, :update, :destroy]

  def create
    @course = current_user.courses.build(course_params)
    if @course.save
      handle_true_false_questions(@course)
      handle_open_answer_questions(@course)

      # Automatically register the current user for the course
      current_user.registrations.create(course: @course)

      flash[:notice] = "Course created and you have been automatically enrolled!"
      redirect_to dashboard_path
    else
      flash[:alert] = "There was an issue creating the course."
      render :new
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
  end

  def index
    @registered_courses = current_user.registrations.includes(course: :questions).map(&:course)
    @attempts = current_user.attempts.includes(:question)

    # Fetch the courses created by the current user
    @created_courses = current_user.courses.order(:title) if current_user.teacher?
  end

  def my_courses
    @created_courses = current_user.courses.order(:title)
  end

  def new
    @course = Course.new
  end

  def submit_answer
    question = Question.find(params[:id])

    if question.question_type == 'open_answer'
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
      handle_true_false_questions(@course)
      handle_open_answer_questions(@course)
      flash[:notice] = "Course updated successfully!"
      redirect_to dashboard_path
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
    params.require(:course).permit(:title, :description, questions_attributes: [
      :id, :content, :question_type, :_destroy, answers_attributes: [:id, :content, :correct, :_destroy]
    ])
  end

  def handle_open_answer_questions(course)
    course.questions.each do |question|
      if question.question_type == 'open_answer'
        correct_answer_content = params[:course][:questions_attributes].values.find { |q| q['content'] == question.content }['answers_attributes']['0']['content']

        question.answers.create!(content: correct_answer_content, correct: true) if question.answers.empty?
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
      if question.question_type == 'true_false'
        unless question.answers.exists?(content: 'True') && question.answers.exists?(content: 'False')
          question.answers.create!(content: 'True', correct: true) unless question.answers.exists?(content: 'True')
          question.answers.create!(content: 'False', correct: false) unless question.answers.exists?(content: 'False')
        end
      end
    end
  end

  def set_course
    @course = Course.find(params[:id])
  end

end
