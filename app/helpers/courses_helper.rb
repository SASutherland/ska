module CoursesHelper
  def question_number_link(course, question, index, attempts)
    attempt = attempts.find { |a| a.question_id == question.id }

    classes = ["question-number"]
    classes << "question-answered" if attempt

    link_to(index + 1, course_question_path(course, question), class: classes.join(" "))
  end
end