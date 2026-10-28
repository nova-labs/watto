import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from "chart.js"

Chart.register(...registerables)

const TIME_ZONE = "America/New_York"

// Fill level trend chart and emptying summary for the dust collector page.
export default class extends Controller {
  static targets = ["canvas", "rangeButton", "timesEmptied", "daysBetween", "fillAtEmptying", "nearlyFull", "emptyings"]
  static values = { url: String, warning: Number, critical: Number, range: { type: String, default: "7d" } }

  connect() {
    this.chart = new Chart(this.canvasTarget, this.chartConfig())
    this.load()
  }

  disconnect() {
    this.chart?.destroy()
  }

  select(event) {
    this.rangeValue = event.currentTarget.dataset.range
    this.rangeButtonTargets.forEach(button => {
      button.classList.toggle("active", button.dataset.range === this.rangeValue)
    })
    this.load()
  }

  async load() {
    try {
      const response = await fetch(`${this.urlValue}?range=${this.rangeValue}`, { headers: { Accept: "application/json" } })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
      this.render(await response.json())
    } catch (error) {
      console.error("Failed to load dust collector history:", error)
      this.emptyingsTarget.innerHTML = `<tr><td colspan="3" class="ps-3 text-danger">Couldn't load history</td></tr>`
    }
  }

  render({ range, points, summary }) {
    const xs = points.map(p => new Date(p.at).getTime())
    const fills = points.map(p => p.fill_percent)

    this.chart.data.labels = xs
    this.chart.data.datasets[0].data = fills
    this.chart.data.datasets[1].data = xs.map(() => this.warningValue)
    this.chart.data.datasets[2].data = xs.map(() => this.criticalValue)
    this.chart.options.scales.x.ticks.callback = (_, index) => formatTick(xs[index], range)
    this.chart.options.plugins.tooltip.callbacks.title = items => formatFull(xs[items[0].dataIndex])
    this.chart.update()

    this.timesEmptiedTarget.textContent = summary.times_emptied
    this.daysBetweenTarget.textContent = summary.average_days_between ?? "—"
    this.fillAtEmptyingTarget.textContent = percent(summary.average_fill_at_emptying)
    this.nearlyFullTarget.textContent = percent(summary.percent_time_nearly_full)

    this.emptyingsTarget.innerHTML = summary.emptyings.length === 0
      ? `<tr><td colspan="3" class="ps-3 text-muted">No emptyings in this range</td></tr>`
      : summary.emptyings.map(e =>
          `<tr><td class="ps-3">${formatFull(new Date(e.at).getTime())}</td><td>${percent(e.level_before)}</td><td>${percent(e.level_after)}</td></tr>`
        ).join("")
  }

  chartConfig() {
    const threshold = (label, color) => ({
      label, data: [], borderColor: color, borderDash: [6, 6], borderWidth: 1.5, pointRadius: 0, fill: false
    })

    return {
      type: "line",
      data: {
        labels: [],
        datasets: [
          {
            label: "Fill %", data: [], borderColor: "#0d6efd", backgroundColor: "rgba(13, 110, 253, 0.1)",
            borderWidth: 2, pointRadius: 0, fill: "origin", spanGaps: false, tension: 0.2
          },
          threshold("Nearly Full", "#ffc107"),
          threshold("Empty the Bag", "#dc3545")
        ]
      },
      options: {
        maintainAspectRatio: false,
        animation: false,
        interaction: { mode: "index", intersect: false },
        scales: {
          x: { ticks: { maxTicksLimit: 8, autoSkip: true, maxRotation: 0 }, grid: { display: false } },
          y: { min: 0, max: 100, ticks: { callback: value => `${value}%` } }
        },
        plugins: {
          legend: { display: false },
          tooltip: {
            filter: item => item.datasetIndex === 0,
            callbacks: { label: item => `Fill: ${percent(item.raw)}` }
          }
        }
      }
    }
  }
}

function percent(value) {
  return value == null ? "—" : `${value.toFixed(1)}%`
}

function formatTick(ms, range) {
  const options = {
    "24h": { hour: "numeric", minute: "2-digit" },
    "7d": { weekday: "short", hour: "numeric" }
  }[range] || { month: "short", day: "numeric" }
  return new Date(ms).toLocaleString("en-US", { timeZone: TIME_ZONE, ...options })
}

function formatFull(ms) {
  return new Date(ms).toLocaleString("en-US", {
    timeZone: TIME_ZONE, month: "short", day: "numeric", hour: "numeric", minute: "2-digit"
  })
}
