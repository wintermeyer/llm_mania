import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    // Add click event listener to handle clicks outside the menu
    document.addEventListener('click', this.handleOutsideClick.bind(this))
  }

  disconnect() {
    // Clean up event listener when controller is disconnected
    document.removeEventListener('click', this.handleOutsideClick.bind(this))
    this.close()
  }

  toggle(event) {
    // Prevent the click from immediately triggering the outside click handler
    event.stopPropagation()
    this.menuTarget.classList.toggle("hidden")
  }

  close() {
    this.menuTarget.classList.add("hidden")
  }

  handleOutsideClick(event) {
    // If the click is outside the menu and the menu is visible, close it
    if (!this.element.contains(event.target) && !this.menuTarget.classList.contains("hidden")) {
      this.close()
    }
  }
} 