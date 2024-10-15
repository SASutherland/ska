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
      <div class="member-item d-flex justify-content-between" style="max-width: 400px;">
        <span class="student-name">${selectedOption.text}</span>
        <i class="fa-solid fa-trash-can remove-icon" data-action="click->add-members#removeMember" style="cursor: pointer;"></i>
      </div>
      <input type="hidden" name="group[student_ids][]" value="${selectedOption.value}">
    `
  
    // Append the list item to the selected members list
    this.listTarget.appendChild(listItem)
  
    // Show the "Group members" section
    this.toggleGroupMembersVisibility()
  
    // Remove the selected student from the dropdown
    selectBox.remove(selectBox.selectedIndex)
  
    // Reset the dropdown to the default option
    selectBox.selectedIndex = 0
  
    // Check if the submit button should be enabled
    this.toggleSubmitButton()
  }

  removeMember(event) {
    const listItem = event.target.closest("li")
    const memberId = listItem.id.replace("member-", "") // Get student ID from the list item
  
    // Get the student's name from the `.student-name` span element
    const studentName = listItem.querySelector('.student-name').textContent.trim()
  
    // Re-add the removed student back to the dropdown
    const selectBox = document.querySelector('select[name="student"]')
  
    const newOption = document.createElement("option")
    newOption.value = memberId
    newOption.text = studentName
  
    // Add the option back to the dropdown
    selectBox.add(newOption)
  
    // Sort the dropdown options alphabetically
    this.sortSelectOptions(selectBox)
  
    // Remove the member from the list
    listItem.remove()
  
    // Hide the "Group members" section if no members are left
    this.toggleGroupMembersVisibility()
  
    // Check if the submit button should be enabled
    this.toggleSubmitButton()
  }

  // Show/Hide the "Group members" section based on whether there are members
  toggleGroupMembersVisibility() {
    const membersSection = document.getElementById("selected-members")
    if (this.listTarget.children.length > 0) {
      membersSection.style.display = "block" // Show the section
    } else {
      membersSection.style.display = "none" // Hide the section
    }
  }

  // Enable/Disable the "Create Group" button based on conditions
  toggleSubmitButton() {
    const submitButton = document.getElementById("submit-group")
    const groupName = document.querySelector('input[name="group[name]"]').value

    // Check if both a group name is entered and at least one student is selected
    if (this.listTarget.children.length > 0 && groupName.trim() !== "") {
      submitButton.disabled = false // Enable the submit button
    } else {
      submitButton.disabled = true // Disable the submit button
    }
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
