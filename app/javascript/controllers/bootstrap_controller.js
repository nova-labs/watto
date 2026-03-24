import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const bootstrap = window.bootstrap
    if (!bootstrap || !bootstrap.Tooltip) {
      console.warn("bootstrap tooltip not available")
      return
    }

    this.tooltip = new bootstrap.Tooltip(this.element, {
      delay: { show: 0, hide: 0 },
      trigger: "click",
    })

    this.isShown = false
    this._onShown = () => { this.isShown = true }
    this._onHidden = () => { this.isShown = false }
    this.element.addEventListener("shown.bs.tooltip", this._onShown)
    this.element.addEventListener("hidden.bs.tooltip", this._onHidden)

    this._onDocumentClick = (event) => {
      if (!this.tooltip || !this.isShown) {
        return
      }
      if (this.element.contains(event.target)) {
        return
      }
      this.tooltip.hide()
    }
    document.addEventListener("click", this._onDocumentClick)
  }

  disconnect() {
    if (this.tooltip) {
      this.tooltip.dispose()
    }
    if (this._onShown) {
      this.element.removeEventListener("shown.bs.tooltip", this._onShown)
    }
    if (this._onHidden) {
      this.element.removeEventListener("hidden.bs.tooltip", this._onHidden)
    }
    if (this._onDocumentClick) {
      document.removeEventListener("click", this._onDocumentClick)
    }
  }

  logClick(event) {
    if (this.tooltip) {
      this.tooltip.toggle()
    }
  }
}
