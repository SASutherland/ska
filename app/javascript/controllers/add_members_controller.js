import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["studentCheckbox"] 

  connect() {
    // Attach a listener to the group name input field
    const groupNameInput = document.querySelector('input[name="group[name]"]')
    groupNameInput.addEventListener('input', this.toggleSubmitButton.bind(this))
  }

  // Toggle the "Select All" functionality
  toggleSelectAll(event) {
    const isChecked = event.target.checked

    // Check or uncheck all student checkboxes
    this.studentCheckboxTargets.forEach(checkbox => {
      checkbox.checked = isChecked
    })
  }
}
