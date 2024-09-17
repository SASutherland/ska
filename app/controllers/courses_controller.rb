class CoursesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_teacher, only: [:new, :create, :edit, :update]
  before_action :set_course, only: [:edit, :update]

  def new
    @course = Course.new
  end

  def create
    @course = current_user.courses.build(course_params)
    if @course.save
      handle_true_false_questions(@course)
      handle_open_answer_questions(@course)
      flash[:notice] = "Course created successfully!"
      redirect_to dashboard_path
    else
      flash[:alert] = "There was an issue creating the course."
      render :new
    end
  end

  def edit
    # @course is already set by set_course
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

  def index
    @registered_courses = current_user.registrations.includes(course: :questions).map(&:course)
    @attempts = current_user.attempts.includes(:question)
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

  def set_course
    @course = Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:title, :description, questions_attributes: [
      :id, :content, :question_type, :_destroy, answers_attributes: [:id, :content, :correct, :_destroy]
    ])
  end

  def authorize_teacher
    redirect_to root_path, alert: "You are not authorized to perform this action." unless current_user.teacher?
  end

  def handle_true_false_questions(course)
    course.questions.each do |question|
      if question.question_type == 'true_false'
        correct_answer = params[:course][:questions_attributes].values.find { |q| q['content'] == question.content }['correct']

        question.answers.create!(content: 'True', correct: correct_answer == 'true') if question.answers.empty?
        question.answers.create!(content: 'False', correct: correct_answer == 'false') if question.answers.empty?
      end
    end
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

    attempt = current_user.attempts.find_or_initialize_by(question: question)

    user_answer = question.answers.find_or_initialize_by(content: user_answer_content, correct: false)
    user_answer.save if user_answer.new_record?

    correct_answer = question.answers.find_by(correct: true)
    attempt.update(chosen_answer: user_answer, correct: user_answer.content.downcase == correct_answer.content.downcase)
  end
end
