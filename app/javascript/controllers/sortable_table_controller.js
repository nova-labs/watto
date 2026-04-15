import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sortable-table"
// Add data-sort-col="N" (0-indexed) to each <th> you want sortable.
// Add data-sort-value="..." to each <td> for the raw sort key.
export default class extends Controller {
  connect() {
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

    this.element.querySelectorAll("thead th").forEach((h, i) => {
      h.classList.remove("sort-asc", "sort-desc")
      if (i === col) {
        h.classList.add(this.sortAsc ? "sort-asc" : "sort-desc")
      }
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
  }
}
