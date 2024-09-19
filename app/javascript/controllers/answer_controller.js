import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["answerButton", "hiddenAnswerField", "form", "timer"]; // Add 'timer' target

  connect() {
    this.checkAndResetTimerForNewCourse();
    this.updateTimerDisplay(); // Show the current time immediately when the page loads
    this.startTimer();

    this.answerButtonTargets.forEach(button => {
      button.addEventListener("click", (event) => {
        this.handleAnswerClick(event);
      });
    });
  }

  checkAndResetTimerForNewCourse() {
    const currentCourseId = this.data.get("courseId");
    const storedCourseId = localStorage.getItem("currentCourseId");

    // If the current course is different from the stored one, reset the timer
    if (storedCourseId !== currentCourseId) {
      this.resetTimer();
      localStorage.setItem("currentCourseId", currentCourseId); // Update with the new course ID
    } else {
      // Retrieve time spent from localStorage if continuing the same course
      this.secondsSpent = parseInt(localStorage.getItem('timeSpent')) || 0;
    }
  }

  resetTimer() {
    this.secondsSpent = 0;
    localStorage.setItem('timeSpent', 0); // Reset the time in localStorage
  }

  startTimer() {
    this.timerInterval = setInterval(() => {
      this.secondsSpent += 1;
      localStorage.setItem('timeSpent', this.secondsSpent); // Store the updated time in localStorage
      this.updateTimerDisplay();
    }, 1000);
  }

  updateTimerDisplay() {
    const timerElement = this.timerTarget;
    if (timerElement) {
      const hours = String(Math.floor(this.secondsSpent / 3600)).padStart(2, '0');
      const minutes = String(Math.floor((this.secondsSpent % 3600) / 60)).padStart(2, '0');
      const seconds = String(this.secondsSpent % 60).padStart(2, '0');

      timerElement.innerHTML = `${hours}:${minutes}:${seconds}`;
    }
  }

  handleAnswerClick(event) {
    const selectedAnswerId = event.target.getAttribute("data-answer-id");
    this.hiddenAnswerFieldTarget.value = selectedAnswerId;
    this.formTarget.submit();  // Automatically submit the form
  }

  disconnect() {
    // Stop the timer if the user navigates away
    clearInterval(this.timerInterval);
  }
}



// import { Controller } from "@hotwired/stimulus";

// export default class extends Controller {
//   static targets = ["answerButton", "hiddenAnswerField", "form"];

//   connect() {
//     this.answerButtonTargets.forEach(button => {
//       button.addEventListener("click", (event) => {
//         this.handleAnswerClick(event);
//       });
//     });
//   }

//   handleAnswerClick(event) {
//     const selectedAnswerId = event.target.getAttribute("data-answer-id");
//     this.hiddenAnswerFieldTarget.value = selectedAnswerId;
//     this.formTarget.submit();  // Submit the form automatically
//   }
// }
