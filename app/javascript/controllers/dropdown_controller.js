import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }

  // Optional: Close dropdown when clicking outside
  disconnect() {
    this.close()
  }

  close() {
    this.menuTarget.classList.add("hidden")
  }
} 