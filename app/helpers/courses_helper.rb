module CoursesHelper
  def question_number_link(course, question, index, attempts)
    attempt = attempts.find { |a| a.question_id == question.id }

    classes = ["question-number"]
    classes << "question-answered" if attempt

    link_to(index + 1, course_question_path(course, question), class: classes.join(" "))
  end

  def levels_list(course)
    return "" if course.levels.empty?

    "(voor #{course.levels.map(&:name).join(", ")})"
  end
end