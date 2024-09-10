class QuestionsController < ApplicationController
  def show
    @course = Course.find(params[:course_id])
    @question = @course.questions.find(params[:id])
    @answers = @question.answers.shuffle
    @attempts = current_user.attempts.joins(:question).where(questions: { course_id: @course.id })
    @question_number = @course.questions.order(:id).pluck(:id).index(@question.id) + 1
    @previous_question = @course.questions.where("id < ?", @question.id).order(id: :desc).first
    @next_question = @course.questions.where("id > ?", @question.id).order(id: :asc).first
  end

  def submit_answer
    @course = Course.find(params[:course_id])
    @question = @course.questions.find(params[:id])

    if @question.question_type == 'open_answer'
      handle_open_answer_submission(@question)
    elsif @question.question_type == 'multiple_answer'
      handle_multiple_answer_submission(@question)
    else
      chosen_answer_id = params[:answer]

      if chosen_answer_id.present?
        handle_multiple_choice_or_true_false_submission(chosen_answer_id)
      else
        flash[:alert] = "Please select an answer before submitting."
        redirect_to course_question_path(@course, @question)
        return
      end
    end

    # Find the next question in the course
    next_question = @course.questions.where("id > ?", @question.id).first

    if next_question
      # Redirect to the next question
      redirect_to course_question_path(@course, next_question)
    else
      # If no more questions, redirect to the dashboard
      redirect_to dashboards_index_path, notice: "You have completed the course!"
    end
  end

  private

  # Handle submission for multiple-choice and true/false questions
  def handle_multiple_choice_or_true_false_submission(chosen_answer_id)
    attempt = current_user.attempts.find_by(question_id: @question.id)

    if attempt
      # Update the existing attempt
      attempt.update(chosen_answer_id: chosen_answer_id)
    else
      # Create a new attempt if one doesn't exist
      current_user.attempts.create(
        question_id: @question.id,
        chosen_answer_id: chosen_answer_id
      )
    end
  end

  # Handle submission for open_answer questions
  def handle_open_answer_submission(question)
    user_answer_content = params[:answer_content]

    # Find or initialize an attempt for this question
    attempt = current_user.attempts.find_or_initialize_by(question: question)

    # Find or create the user's answer based on input
    user_answer = question.answers.find_or_initialize_by(content: user_answer_content)
    user_answer.save if user_answer.new_record?

    # Find the correct answer
    correct_answer = question.answers.find_by(correct: true)

    # Check if the user's answer matches the correct answer
    is_correct = user_answer_content.strip.downcase == correct_answer.content.strip.downcase

    # Update the attempt with the user's written answer and correctness
    attempt.update(written_answer: user_answer_content, correct: is_correct)
  end


  # Handle submission for multiple_answer questions
  def handle_multiple_answer_submission(question)
    chosen_answer_ids = params[:answer_ids] || []

    if chosen_answer_ids.any?
      # Check which answers are correct and update or create the attempt
      correct_answer_ids = question.answers.where(correct: true).pluck(:id)
      is_correct = (chosen_answer_ids.map(&:to_i) - correct_answer_ids).empty?

      attempt = current_user.attempts.find_or_initialize_by(question: question)

      # Update the attempt with the chosen answers
      attempt.chosen_answers = Answer.where(id: chosen_answer_ids)  # Save multiple chosen answers
      attempt.update(correct: is_correct)  # Update the correctness of the attempt
    else
      flash[:alert] = "Please select at least one answer before submitting."
      redirect_to course_question_path(@course, @question)
      return
    end
  end
end
