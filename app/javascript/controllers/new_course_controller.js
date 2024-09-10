import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["questionsContainer", "questionTypeDropdown"];

  connect() {
    this.questionCount = 0;
  }

  addQuestion() {
    this.questionCount++;
    const questionNumber = this.questionCount;
    const selectedQuestionType = this.questionTypeDropdownTarget.value;

    let questionHTML = `
      <div class="question-fields mb-4">
        <h4 class="new-question">Question ${questionNumber}</h4>
        <div class="form-group">
          <label for="course_questions_attributes_${questionNumber}_content">Question</label>
          <input type="text" name="course[questions_attributes][${questionNumber}][content]" id="course_questions_attributes_${questionNumber}_content" class="form-control" style="max-width: 600px;">
        </div>
        <input type="hidden" name="course[questions_attributes][${questionNumber}][question_type]" value="${selectedQuestionType}">
        <div class="answers mt-2">
          <h4 class="new-question">Answers</h4>`;

    if (selectedQuestionType === 'multiple_choice' || selectedQuestionType === 'multiple_answer') {
      questionHTML += [...Array(4)].map((_, i) => `
        <div class="answer-fields d-flex align-items-center mb-2">
          <div class="form-group d-flex align-items-center" style="width: 100%;">
            <input type="text" name="course[questions_attributes][${questionNumber}][answers_attributes][${i}][content]" id="course_questions_attributes_${questionNumber}_answers_attributes_${i}_content" class="form-control" style="max-width: 495px; margin-right: 10px;">
            <div class="form-check">
              <input type="checkbox" name="course[questions_attributes][${questionNumber}][answers_attributes][${i}][correct]" id="course_questions_attributes_${questionNumber}_answers_attributes_${i}_correct" class="form-check-input">
              <label class="form-check-label" for="course_questions_attributes_${questionNumber}_answers_attributes_${i}_correct">Correct</label>
            </div>
          </div>
        </div>
      `).join('');
    }

    questionHTML += `
        </div>
      </div>
    `;

    this.questionsContainerTarget.insertAdjacentHTML('beforeend', questionHTML);
  }
}
