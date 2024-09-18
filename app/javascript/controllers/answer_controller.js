import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["answerButton", "hiddenAnswerField", "form"];

  connect() {
    this.answerButtonTargets.forEach(button => {
      button.addEventListener("click", (event) => {
        this.handleAnswerClick(event);
      });
    });
  }

  handleAnswerClick(event) {
    const selectedAnswerId = event.target.getAttribute("data-answer-id");
    this.hiddenAnswerFieldTarget.value = selectedAnswerId;
    this.formTarget.submit();  // Submit the form automatically
  }
}
