import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sortable-table"
// Add data-sort-col="N" (0-indexed) to each <th> you want sortable.
// Add data-sort-value="..." to each <td> for the raw sort key.
// Add data-action="input->sortable-table#filterRows" data-sort-col="N" to filter inputs.
export default class extends Controller {
  static targets = ["filterRow"]

  connect() {
    this.filters = {}

    // Pick up any pre-sorted column indicated in the markup
    const activeHeader = this.element.querySelector("thead th.sort-asc, thead th.sort-desc")
    if (activeHeader) {
      this.sortCol = parseInt(activeHeader.dataset.sortCol)
      this.sortAsc = activeHeader.classList.contains("sort-asc")
    } else {
      this.sortCol = null
      this.sortAsc = true
    }
  }

  sort(event) {
    const th = event.currentTarget
    const col = parseInt(th.dataset.sortCol)

    if (this.sortCol === col) {
      this.sortAsc = !this.sortAsc
    } else {
      this.sortCol = col
      this.sortAsc = true
    }

    this.element.querySelectorAll("thead th[data-sort-col]").forEach(h => {
      const hCol = parseInt(h.dataset.sortCol)
      h.classList.remove("sort-asc", "sort-desc")
      if (hCol === col) h.classList.add(this.sortAsc ? "sort-asc" : "sort-desc")
    })

    const tbody = this.element.querySelector("tbody")
    const rows = Array.from(tbody.querySelectorAll("tr"))

    rows.sort((a, b) => {
      const aRaw = a.querySelectorAll("td")[col]?.dataset.sortValue ?? ""
      const bRaw = b.querySelectorAll("td")[col]?.dataset.sortValue ?? ""

      const aNum = parseFloat(aRaw)
      const bNum = parseFloat(bRaw)

      const cmp = (!isNaN(aNum) && !isNaN(bNum))
        ? aNum - bNum
        : aRaw.localeCompare(bRaw)

      return this.sortAsc ? cmp : -cmp
    })

    rows.forEach(row => tbody.appendChild(row))
    this._applyFilters()
  }

  toggleFilter(event) {
    event.preventDefault()
    const row = this.filterRowTarget
    const hidden = row.classList.toggle("d-none")
    if (hidden) {
      row.querySelectorAll("input").forEach(i => { i.value = "" })
      this.filters = {}
      this._applyFilters()
    } else {
      row.querySelector("input")?.focus()
    }
  }

  filterRows(event) {
    const col = parseInt(event.currentTarget.dataset.sortCol)
    const val = event.currentTarget.value.trim().toLowerCase()

    if (val) {
      this.filters[col] = val
    } else {
      delete this.filters[col]
    }

    this._applyFilters()
  }

  _applyFilters() {
    const activeFilters = Object.entries(this.filters)
    this.element.querySelector("tbody").querySelectorAll("tr").forEach(row => {
      const tds = row.querySelectorAll("td")
      const visible = activeFilters.every(([col, term]) => {
        const td = tds[parseInt(col)]
        return td && td.textContent.trim().toLowerCase().includes(term)
      })
      row.style.display = visible ? "" : "none"
    })
  }
}
