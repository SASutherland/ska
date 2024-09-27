import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  connect() {
    this.initializeTomSelect()
  }

  initializeTomSelect() {
    console.log(Object.getOwnPropertyNames(TomSelect)); // List own properties
    console.log(Object.getOwnPropertyNames(Object.getPrototypeOf(TomSelect))); // List prototype properties
    console.log(Object.getPrototypeOf(TomSelect)); // Logs the prototype of the module

    new TomSelect(this.element, {
      plugins: ["remove_button"], // Allows users to remove selected items
      // You can add other Tom Select options here
    })
  }
}
