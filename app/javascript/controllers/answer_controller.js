import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["answerButton", "hiddenAnswerField", "form", "timer"];

  connect() {
    this.checkAndResetTimerForNewCourse();
    this.updateTimerDisplay();
    this.startTimer();

    // Save time spent when user navigates away from the page
    window.addEventListener("beforeunload", this.saveTimeSpent.bind(this));
  }

  handleAnswerClick(event) {
    // Debugging Log
    console.log("Answer button clicked");

    const selectedAnswerId = event.target.getAttribute("data-answer-id");

    if (selectedAnswerId) {
      console.log(`Selected answer ID: ${selectedAnswerId}`);
      // Set the selected answer in the hidden field
      this.hiddenAnswerFieldTarget.value = selectedAnswerId;

      // Automatically submit the form for students
      if (!this.isTeacherOrAdmin()) {
        console.log("Submitting the form for the student...");
        this.formTarget.submit();
      }
    } else {
      console.error("Could not find the answer ID.");
    }
  }

  checkAndResetTimerForNewCourse() {
    const currentCourseId = this.data.get("courseId");
    const storedCourseId = localStorage.getItem("currentCourseId");

    if (storedCourseId !== currentCourseId) {
      this.resetTimer();
      localStorage.setItem("currentCourseId", currentCourseId);
    } else {
      this.secondsSpent = parseInt(localStorage.getItem("timeSpent")) || 0;
    }
  }

  resetTimer() {
    this.secondsSpent = 0;
    localStorage.setItem("timeSpent", 0);
  }

  startTimer() {
    this.timerInterval = setInterval(() => {
      this.secondsSpent += 1;
      localStorage.setItem("timeSpent", this.secondsSpent);
      this.updateTimerDisplay();
    }, 1000);
  }

  updateTimerDisplay() {
    const timerElement = this.timerTarget;
    if (timerElement) {
      const hours = String(Math.floor(this.secondsSpent / 3600)).padStart(2, "0");
      const minutes = String(Math.floor((this.secondsSpent % 3600) / 60)).padStart(2, "0");
      const seconds = String(this.secondsSpent % 60).padStart(2, "0");

      timerElement.innerHTML = `${hours}:${minutes}:${seconds}`;
    }
  }

  disconnect() {
    clearInterval(this.timerInterval);
    this.saveTimeSpent(); // Save when leaving the page
  }

  saveTimeSpent() {
    const courseId = this.data.get("courseId");
    const timeSpent = this.secondsSpent;

    // Send the time spent to the backend
    fetch(`/registrations/update_time_spent`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
      },
      body: JSON.stringify({ course_id: courseId, time_spent: timeSpent }),
    })
      .then((response) => response.json())
      .then((data) => {
        if (!data.success) {
          console.error("Failed to save time spent:", data.errors || data.error);
        }
      })
      .catch((error) => {
        console.error("Error saving time spent:", error);
      });
  }

  isTeacherOrAdmin() {
    return document.body.classList.contains("teacher-role") || document.body.classList.contains("admin-role");
  }
}