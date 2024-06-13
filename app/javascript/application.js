// Entry point for the build script in your package.json
import Rails from "@rails/ujs"
// import Turbolinks from "turbolinks"
// import * as ActiveStorage from "@rails/activestorage"

import '@popperjs/core'
import 'bootstrap/js/dist/dropdown'
Rails.start()
// Turbolinks.start()
// ActiveStorage.start()

import "./controllers"
import "@hotwired/turbo-rails"
