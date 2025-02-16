import { Controller } from "@hotwired/stimulus"

/**
 * Navigation controller handles the mobile navigation menu functionality
 * @extends Controller
 */
export default class extends Controller {
  /** @type {string[]} */
  static targets = ["mobileMenu"]

  connect() {
    // Ensure menu starts hidden
    this.mobileMenuTarget.style.display = 'none'

    // Add click event listener to handle clicks outside the menu
    document.addEventListener('click', this.handleOutsideClick.bind(this))
  }

  disconnect() {
    // Clean up event listener when controller is disconnected
    document.removeEventListener('click', this.handleOutsideClick.bind(this))
  }

  /**
   * Handles clicks outside the navigation menu
   * @param {Event} event - The click event
   */
  handleOutsideClick(event) {
    const menu = this.mobileMenuTarget
    const isVisible = menu.style.display === "block"

    // Check if the click was outside the menu and the menu is visible
    if (isVisible && !menu.contains(event.target) && !event.target.closest('[data-action*="navigation#toggleSidebar"]')) {
      this.toggleSidebar(event)
    }
  }

  /**
   * Toggles the mobile navigation menu visibility
   * @param {Event} event - The click event
   */
  toggleSidebar(event) {
    event.preventDefault()

    const menu = this.mobileMenuTarget
    const isHidden = menu.style.display === "none" || menu.style.display === ""

    // Toggle visibility
    menu.style.display = isHidden ? "block" : "none"

    // Update aria-expanded on the clicked button
    const button = event.currentTarget
    if (button) {
      button.setAttribute("aria-expanded", isHidden)
    }
  }

  showMobileMenu() {
    this.mobileMenuTarget.classList.remove('hidden', '-translate-x-full')
    this.mobileMenuTarget.classList.add('block', 'translate-x-0')
  }

  hideMobileMenu() {
    this.mobileMenuTarget.classList.remove('block', 'translate-x-0')
    this.mobileMenuTarget.classList.add('hidden', '-translate-x-full')
  }
} 