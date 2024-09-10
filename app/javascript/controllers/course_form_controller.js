import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["questionsContainer", "questionTypeDropdown"];

  connect() {
    this.questionCount = 0;
  }

  // Method to add a new question
  addQuestion(event) {
    event.preventDefault();
    this.questionCount++;
    const questionNumber = this.questionCount;
    const selectedQuestionType = this.questionTypeDropdownTarget.value;

    // Generate the HTML for the question based on the selected type
    let questionHTML = `
      <div class="question-fields mb-4" data-question-number="${questionNumber}">
        <h4 class="new-question">
          Question ${questionNumber}
          <button type="button" class="btn remove-question-button text-danger" data-action="click->course-form#removeQuestion">
            <i class="fa-solid fa-circle-xmark"></i>
          </button>
        </h4>
        <div class="form-group">
          <label for="course_questions_attributes_${questionNumber}_content">Question</label>
          <input type="text" name="course[questions_attributes][${questionNumber}][content]" id="course_questions_attributes_${questionNumber}_content" class="form-control" style="max-width: 600px;">
        </div>
        <input type="hidden" name="course[questions_attributes][${questionNumber}][question_type]" value="${selectedQuestionType}">
        <div class="answers mt-2">`;

    if (selectedQuestionType === 'multiple_choice' || selectedQuestionType === 'multiple_answer') {
      questionHTML += this.generateMultipleChoiceHTML(questionNumber, selectedQuestionType);
    } else if (selectedQuestionType === 'open_answer') {
      questionHTML += this.generateOpenAnswerHTML(questionNumber);
    } else if (selectedQuestionType === 'true_false') {
      questionHTML += this.generateTrueFalseHTML(questionNumber);
    } else if (selectedQuestionType === 'matching') {
      questionHTML += this.generateMatchingHTML(questionNumber);
    } else if (selectedQuestionType === 'ordering') {
      questionHTML += this.generateOrderingHTML(questionNumber);
    }

    questionHTML += `</div></div>`;

    // Insert the question HTML into the questions container
    this.questionsContainerTarget.insertAdjacentHTML('beforeend', questionHTML);

    // Add checkbox enforcement for Multiple-Choice
    if (selectedQuestionType === 'multiple_choice') {
      this.enforceSingleChoice(questionNumber);
    }
  }

  // Method to remove a question
  removeQuestion(event) {
    event.target.closest(".question-fields").remove();
    this.renumberQuestions();
  }

  // Method to renumber questions after one is removed
  renumberQuestions() {
    const questionFields = this.questionsContainerTarget.querySelectorAll(".question-fields");
    questionFields.forEach((field, index) => {
      const questionNumberSpan = field.querySelector(".new-question");
      questionNumberSpan.innerHTML = `Question ${index + 1}
        <button type="button" class="btn remove-question-button text-danger" data-action="click->course-form#removeQuestion">
          <i class="fa-solid fa-circle-xmark"></i>
        </button>`;
    });
    this.questionCount = questionFields.length;
  }

  // Helper method to generate HTML for Multiple-Choice and Multiple-Answer
  generateMultipleChoiceHTML(questionNumber, selectedQuestionType) {
    const isMultipleChoice = selectedQuestionType === 'multiple_choice';
    return [...Array(4)].map((_, i) => `
      <div class="answer-fields d-flex align-items-center mb-2">
        <div class="form-group d-flex align-items-center" style="width: 100%;">
          <input type="text" name="course[questions_attributes][${questionNumber}][answers_attributes][${i}][content]" id="course_questions_attributes_${questionNumber}_answers_attributes_${i}_content" class="form-control" style="max-width: 495px; margin-right: 10px;">
          <div class="form-check">
            <input type="checkbox" name="course[questions_attributes][${questionNumber}][answers_attributes][${i}][correct]" id="course_questions_attributes_${questionNumber}_answers_attributes_${i}_correct" class="form-check-input multiple-choice-checkbox" data-question-number="${questionNumber}" ${isMultipleChoice ? 'data-multiple-choice="true"' : ''}>
            <label class="form-check-label" for="course_questions_attributes_${questionNumber}_answers_attributes_${i}_correct">Correct</label>
          </div>
        </div>
      </div>
    `).join('');
  }

  // Helper method to generate HTML for Open Answer
  generateOpenAnswerHTML(questionNumber) {
    return `
      <div class="answer-fields mb-2">
        <div class="form-group">
          <label for="course_questions_attributes_${questionNumber}_answers_attributes_0_content">Answer</label>
          <input type="text" name="course[questions_attributes][${questionNumber}][answers_attributes][0][content]" id="course_questions_attributes_${questionNumber}_answers_attributes_0_content" class="form-control" style="max-width: 600px;">
        </div>
      </div>`;
  }

  // Helper method to generate HTML for True/False
  generateTrueFalseHTML(questionNumber) {
    return `
      <div class="form-check">
        <input type="radio" name="course[questions_attributes][${questionNumber}][correct]" value="true" class="form-check-input">
        <label class="form-check-label">True</label>
      </div>
      <div class="form-check">
        <input type="radio" name="course[questions_attributes][${questionNumber}][correct]" value="false" class="form-check-input">
        <label class="form-check-label">False</label>
      </div>`;
  }

  // Helper method to generate HTML for Matching
  generateMatchingHTML(questionNumber) {
    return [...Array(4)].map((_, i) => `
      <div class="answer-fields d-flex align-items-center mb-2">
        <div class="form-group d-flex justify-content-between align-items-center" style="max-width: 600px; width: 100%;">
          <input type="text" name="course[questions_attributes][${questionNumber}][answers_attributes][${i}][content]" class="form-control" placeholder="Item to match" style="max-width: 45%;">
          <span style="margin: 0 10px;">⇔</span>
          <input type="text" name="course[questions_attributes][${questionNumber}][answers_attributes][${i}][match]" class="form-control" placeholder="Matching pair" style="max-width: 45%;">
        </div>
      </div>
    `).join('');
  }

  // Helper method to generate HTML for Ordering
  generateOrderingHTML(questionNumber) {
    return [...Array(4)].map((_, i) => `
      <div class="answer-fields mb-2">
        <input type="text" name="course[questions_attributes][${questionNumber}][answers_attributes][${i}][content]" class="form-control" style="max-width: 600px;" placeholder="Order item ${i + 1}">
      </div>
    `).join('');
  }

  // Ensure only one "Correct" checkbox is selected for Multiple-Choice questions
  enforceSingleChoice(questionNumber) {
    const checkboxes = document.querySelectorAll(`.multiple-choice-checkbox[data-question-number="${questionNumber}"]`);

    checkboxes.forEach(checkbox => {
      checkbox.addEventListener('change', function() {
        if (this.checked) {
          // Uncheck all other checkboxes in the same question group
          checkboxes.forEach(otherCheckbox => {
            if (otherCheckbox !== this) {
              otherCheckbox.checked = false;
            }
          });
        }
      });
    });
  }
}
