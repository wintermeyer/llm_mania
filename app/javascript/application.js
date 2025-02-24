// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Import Alpine.js and its plugins
import Alpine from "alpinejs"
import Focus from "@alpinejs/focus"
import Collapse from "@alpinejs/collapse"
import Persist from "@alpinejs/persist"

// Register Alpine.js plugins
Alpine.plugin(Focus)
Alpine.plugin(Collapse)
Alpine.plugin(Persist)

// Make Alpine available globally
window.Alpine = Alpine

// Start Alpine.js
Alpine.start()
