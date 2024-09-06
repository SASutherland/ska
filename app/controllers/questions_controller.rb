class QuestionsController < ApplicationController
  def show
    @course = Course.find(params[:course_id])
    @question = @course.questions.find(params[:id])
    @answers = @question.answers
    @attempts = current_user.attempts.joins(:question).where(questions: { course_id: @course.id })
    @question_number = @course.questions.order(:id).pluck(:id).index(@question.id) + 1
    @previous_question = @course.questions.where("id < ?", @question.id).order(id: :desc).first
    @next_question = @course.questions.where("id > ?", @question.id).order(id: :asc).first
  end

  def submit_answer
    @course = Course.find(params[:course_id])
    @question = @course.questions.find(params[:id])
    chosen_answer_id = params[:answer]

    if chosen_answer_id.present?
      # Find the existing attempt for this question or create a new one
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

      # Find the next question in the course
      next_question = @course.questions.where("id > ?", @question.id).first

      if next_question
        # Redirect to the next question
        redirect_to course_question_path(@course, next_question)
      else
        # If no more questions, redirect to the dashboard
        redirect_to dashboards_index_path, notice: "You have completed the course!"
      end
    else
      flash[:alert] = "Please select an answer before submitting."
      redirect_to course_question_path(@course, @question)
    end
  end
end
