import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="add-course"
export default class extends Controller {
  static targets = ["dropdownItem", "dropdownButton", "selectedCourseInput", "registerButton"]

  connect() {
    this.registerButtonTarget.disabled = true
  }

  selectCourse(event) {
    event.preventDefault()
    const courseId = event.currentTarget.dataset.courseId
    const courseTitle = event.currentTarget.dataset.courseTitle

    // Update hidden input with selected course ID
    this.selectedCourseInputTarget.value = courseId

    // Update the dropdown button text with the selected course title
    this.dropdownButtonTarget.textContent = courseTitle

    // Enable the register button
    this.registerButtonTarget.disabled = false
  }
}
