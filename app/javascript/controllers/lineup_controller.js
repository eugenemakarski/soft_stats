// app/javascript/controllers/lineup_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["rowsContainer", "row", "rowTemplate", "playerSelect", "orderLabel", "pitcherSelect"]
  static values = { players: Array }

  connect() {
    this.playerSelectTargets.forEach((select) => this.populateSelect(select, select.dataset.selected))
    if (this.hasPitcherSelectTarget) {
      this.populateSelect(this.pitcherSelectTarget, this.pitcherSelectTarget.dataset.selected)
    }
    this.refresh()
  }

  add() {
    this.rowsContainerTarget.insertAdjacentHTML("beforeend", this.rowTemplateTarget.innerHTML)
    this.populateSelect(this.playerSelectTargets[this.playerSelectTargets.length - 1])
    this.refresh()
  }

  remove(event) {
    event.target.closest("[data-lineup-target='row']").remove()
    this.refresh()
  }

  refresh() {
    const chosen = this.playerSelectTargets.map((select) => select.value).filter((value) => value !== "")

    this.orderLabelTargets.forEach((label, index) => (label.textContent = index + 1))

    this.playerSelectTargets.forEach((select) => {
      const excluding = chosen.filter((id) => id !== select.value)
      this.populateSelect(select, select.value, excluding)
    })
  }

  populateSelect(select, preselect = select.value, excludeIds = []) {
    const current = preselect || ""
    select.innerHTML = ""
    select.appendChild(new Option("Select player…", ""))
    this.playersValue
      .filter((player) => !excludeIds.includes(String(player.id)))
      .forEach((player) => select.appendChild(new Option(player.name, String(player.id))))
    select.value = current
  }
}
