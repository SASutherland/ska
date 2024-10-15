import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list"]

  addMember(event) {
    const selectBox = event.target
    const selectedOption = selectBox.options[selectBox.selectedIndex]

    // Check if the student has already been added
    if (this.listTarget.querySelector(`#member-${selectedOption.value}`)) {
      alert("This student is already added.")
      return
    }

    // Create a new list item for the selected student
    const listItem = document.createElement("li")
    listItem.id = `member-${selectedOption.value}`
    listItem.innerHTML = `
      ${selectedOption.text}
      <input type="hidden" name="group[student_ids][]" value="${selectedOption.value}">
      <button type="button" data-action="click->add-members#removeMember" class="btn btn-sm btn-danger ml-2">Remove</button>
    `

    // Append the list item to the selected members list
    this.listTarget.appendChild(listItem)

    // Remove the selected student from the dropdown
    selectBox.remove(selectBox.selectedIndex)

    // Reset the dropdown to the default option
    selectBox.selectedIndex = 0
  }

  removeMember(event) {
    const listItem = event.target.closest("li")
    const memberId = listItem.id.replace("member-", "") // Get student ID from the list item

    // Re-add the removed student back to the dropdown
    const selectBox = document.querySelector('select[name="student"]')
    const studentName = listItem.firstChild.textContent.trim()

    const newOption = document.createElement("option")
    newOption.value = memberId
    newOption.text = studentName

    // Add the option back to the dropdown
    selectBox.add(newOption)

    // Sort the dropdown options alphabetically
    this.sortSelectOptions(selectBox)

    // Remove the member from the list
    listItem.remove()
  }

  // Helper function to sort the select options alphabetically by text
  sortSelectOptions(selectBox) {
    // Separate the placeholder option ("Select a Student") from the rest
    const placeholderOption = Array.from(selectBox.options).find(option => option.value === "")
    const options = Array.from(selectBox.options).filter(option => option.value !== "")

    // Sort the options by the text (student name)
    options.sort((a, b) => {
      if (a.text.toLowerCase() < b.text.toLowerCase()) return -1
      if (a.text.toLowerCase() > b.text.toLowerCase()) return 1
      return 0
    })

    // Remove all options from the select box
    selectBox.innerHTML = ""

    // Re-add the placeholder option first, if it exists
    if (placeholderOption) {
      selectBox.add(placeholderOption)
    }

    // Append the sorted options back to the select box
    options.forEach(option => selectBox.add(option))
  }
}
