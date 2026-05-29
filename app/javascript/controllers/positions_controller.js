// app/javascript/controllers/positions_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template"]

  add() {
    const timestamp = new Date().getTime()
    const html = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, timestamp)
    document.getElementById("position-rows").insertAdjacentHTML("beforeend", html)
  }
}
