class AttemptsController < ApplicationController
  def create
    @question = Question.find(params[:question_id])
    @course = @question.course
    user_answer_content = params[:answer_content].strip

    # Check if the user has already answered this question
    attempt = current_user.attempts.find_or_initialize_by(question: @question)

    if @question.question_type == 'open_answer'
      # Check if the correct answer exists for the question
      correct_answer = @question.answers.find_by(correct: true)

      # Find or create the user's submitted answer
      user_answer = @question.answers.find_or_initialize_by(content: user_answer_content)

      # Determine if the user's answer is correct
      is_correct = correct_answer.content.strip.downcase == user_answer_content.downcase

      # Save the attempt and user's answer
      user_answer.correct = is_correct
      user_answer.save!
      attempt.chosen_answer_id = user_answer.id
      attempt.correct = is_correct
      attempt.save!
    end

    redirect_to next_question_path(@course, @question)
  end
end
