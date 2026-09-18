// app/javascript/controllers/sortable_table_controller.js
//
// Client-side column sorting for the stats tables.
//
// This replaces an inline <script> that wired itself up on DOMContentLoaded.
// Turbo Drive swaps the <body> without ever reloading the document, so that
// event had already fired and the listeners were never attached — sorting only
// worked after a manual refresh. Stimulus connect() runs on every Turbo visit,
// which is what fixes it.
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["header", "body"]

  sort(event) {
    const header = event.currentTarget
    const index = this.headerTargets.indexOf(header)
    if (index === -1 || !this.hasBodyTarget) return

    // First click on a column sorts descending (highest first is what you want
    // from a stat line); clicking the active column toggles.
    const ascending = header.classList.contains("desc")
    const direction = ascending ? 1 : -1
    const numeric = (header.dataset.sortType || "number") === "number"

    this.headerTargets.forEach((target) => target.classList.remove("asc", "desc"))
    header.classList.add(ascending ? "asc" : "desc")

    const rows = Array.from(this.bodyTarget.rows)
    rows.sort((rowA, rowB) => {
      const a = this.cellValue(rowA, index)
      const b = this.cellValue(rowB, index)

      if (numeric) {
        const numberA = parseFloat(a)
        const numberB = parseFloat(b)
        return direction * ((isNaN(numberA) ? 0 : numberA) - (isNaN(numberB) ? 0 : numberB))
      }

      return direction * a.localeCompare(b)
    })

    // Reattach in one pass so the browser only reflows once.
    const fragment = document.createDocumentFragment()
    rows.forEach((row) => fragment.appendChild(row))
    this.bodyTarget.appendChild(fragment)
  }

  // Indexed against [data-value] cells rather than row.children so the mapping
  // survives adding a non-data column later.
  cellValue(row, index) {
    const cell = row.querySelectorAll("[data-value]")[index]
    return cell ? cell.dataset.value : ""
  }
}
