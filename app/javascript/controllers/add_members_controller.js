import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = []

  connect() {
    // Attach event listeners to all student checkboxes
    const checkboxes = document.querySelectorAll('.student-checkbox')
    checkboxes.forEach(checkbox => {
      checkbox.addEventListener('change', this.toggleSubmitButton.bind(this))
    })

    // Attach a listener to the group name input field
    const groupNameInput = document.querySelector('input[name="group[name]"]')
    groupNameInput.addEventListener('input', this.toggleSubmitButton.bind(this))
  }

  toggleSubmitButton() {
    const submitButton = document.getElementById("submit-group")
    const groupName = document.querySelector('input[name="group[name]"]').value

    // Check if any student checkboxes are selected
    const isAnyStudentSelected = Array.from(document.querySelectorAll('.student-checkbox'))
      .some(checkbox => checkbox.checked)

    // Enable the submit button if group name is provided and at least one student is selected
    submitButton.disabled = !(isAnyStudentSelected && groupName.trim() !== "")
  }
}
