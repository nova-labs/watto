import { Controller } from "@hotwired/stimulus"
import BagView from "bag_view"

const REFRESH_MS = 60000
const BADGES = {
  normal: "bg-success",
  warning: "bg-warning text-dark",
  critical: "bg-danger",
  fault: "bg-secondary",
  offline: "bg-secondary"
}

// Live view of the dust collector bag level. The page is rendered server side;
// this draws the bag and refreshes the numbers once a minute.
export default class extends Controller {
  static targets = [
    "lastReading", "levelFill", "levelPercent", "levelVolume", "bag", "caption",
    "badge", "fill", "volume", "room", "signal", "raw", "readAt", "checkedAt", "error"
  ]
  static values = { url: String, status: Object }

  connect() {
    BagView.init(this.bagTarget, this.statusValue.bag_capacity_yd3)
    this.render(this.statusValue)
    this.timer = setInterval(() => this.refresh(), REFRESH_MS)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  async refresh() {
    try {
      const response = await fetch(this.urlValue, { headers: { Accept: "application/json" }, cache: "no-store" })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
      this.render(await response.json())
    } catch (error) {
      console.error("Failed to refresh dust collector level:", error)
      this.lastReadingTarget.textContent = "Can't reach Watto, showing the last known level"
    }
  }

  render(data) {
    const { reading, status } = data
    const stale = status === "offline" || status === "fault"

    this.badgeTarget.textContent = data.status_label
    this.badgeTarget.className = `float-end badge ${BADGES[status]}`
    this.checkedAtTarget.textContent = formatTime(data.checked_at)
    this.errorTarget.textContent = data.error || ""
    this.errorTarget.classList.toggle("d-none", !data.error)

    if (!reading) {
      this.lastReadingTarget.textContent = "No gauge readings yet"
      BagView.setLevel(0, true)
      return
    }

    const fill = reading.fill_percent
    const capacity = data.bag_capacity_yd3

    this.lastReadingTarget.textContent = `Last reading: ${formatTime(reading.read_at)}`

    this.levelFillTarget.style.height = `${fill}%`
    this.levelFillTarget.className = `level-fill ${status}`
    this.levelPercentTarget.textContent = `${Math.round(fill)}%`
    this.levelPercentTarget.className = `level-percent ${status}`
    this.levelVolumeTarget.textContent = yd3(data.volume_yd3)

    BagView.setLevel(fill / 100, stale)
    this.captionTarget.innerHTML =
      `<strong>${yd3(data.volume_yd3)}</strong> <span class="text-muted">of sawdust in a ${capacity} yd³ bag</span>`

    this.fillTarget.textContent = `${fill.toFixed(1)}%`
    this.volumeTarget.textContent = yd3(data.volume_yd3)
    this.roomTarget.textContent = yd3(data.room_left_yd3)
    this.signalTarget.textContent = `${reading.current_ma.toFixed(2)} mA`
    this.rawTarget.textContent = reading.raw
    this.readAtTarget.textContent = formatTime(reading.read_at)
  }
}

function yd3(value) {
  return value == null ? "—" : `${value.toFixed(2)} yd³`
}

function formatTime(iso) {
  if (!iso) return "—"
  return new Date(iso).toLocaleTimeString("en-US", {
    timeZone: "America/New_York", hour: "numeric", minute: "2-digit"
  })
}
