// app/javascript/controllers/tooltip_controller.js
import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

    console.log("ouch")
export default class extends Controller {
  connect() {
    this.tooltip = new bootstrap.Tooltip(this.element)
  }

  disconnect() {
    if (this.tooltip) {
      this.tooltip.dispose()
    }
  }
}

