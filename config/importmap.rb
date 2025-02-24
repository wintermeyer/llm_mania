# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"

# Alpine.js and its plugins
pin "alpinejs", to: "https://ga.jspm.io/npm:alpinejs@3.14.8/dist/module.esm.js"
pin "@alpinejs/focus", to: "https://ga.jspm.io/npm:@alpinejs/focus@3.14.8/dist/module.esm.js"
pin "@alpinejs/collapse", to: "https://ga.jspm.io/npm:@alpinejs/collapse@3.14.8/dist/module.esm.js"
pin "@alpinejs/persist", to: "https://ga.jspm.io/npm:@alpinejs/persist@3.14.8/dist/module.esm.js"
