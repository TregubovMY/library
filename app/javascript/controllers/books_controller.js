import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ 'books']
  static values = {
    admin: String
  }

  connect() {
    console.log(this.adminValue)
  }

  bookTargetConnected(element) {
    const bookManage = element.querySelector('.book-manage')
    const borrowingManage = element.querySelector('.borrowing-manage')

    if(borrowingManage && this.adminValue === 'admin') {
      borrowingManage.remove()
    }
    else if(bookManage && this.adminValue === 'user'){
      bookManage.remove()
    }
    else{
      borrowingManage.remove()
      bookManage.remove()
    }
  }
}
