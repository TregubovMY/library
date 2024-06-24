import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['description']

  connect() {
  }

  showDescription(e) {
    console.log(e.target)
    if (e.target.tagName.toLowerCase() !== 'a') {
         this.descriptionTarget.classList.toggle('d-none')
       }
  }
}
