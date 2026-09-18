// app/javascript/controllers/scorebook_controller.js
//
// Drives the in-game scorebook: which inning is showing, and whether you're
// looking at the batting or the fielding half. Both panels used to render side
// by side for all nine innings at once.
//
// This replaces the Flowbite tablist that was here. Flowbite itself works fine
// across Turbo Drive visits (importmap pins flowbite.turbo.min.js, which
// re-inits on turbo:load), but it owns its tab state internally, so a "go to
// current inning" button outside the tablist can't drive it. Rendering the
// active panel from the server also avoids the flash of all nine innings while
// the CDN script parses.
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["inningTab", "halfTab", "panel", "inningTablist"]
  static values = {
    inning: Number,
    half: String,
    currentInning: Number,
    activeHalf: String,
    gameId: Number
  }

  connect() {
    const stored = this.restore()
    this.inningValue = stored.inning || this.currentInningValue
    this.halfValue = stored.half || this.defaultHalf
    this.render()
  }

  inningValueChanged() { this.render() }
  halfValueChanged() { this.render() }

  selectInning(event) {
    this.inningValue = Number(event.currentTarget.dataset.inning)
  }

  selectHalf(event) {
    this.halfValue = event.currentTarget.dataset.half
  }

  goToCurrent() {
    this.inningValue = this.currentInningValue
    this.halfValue = this.defaultHalf

    // Un-hide first: scrollIntoView on a display:none element does nothing.
    requestAnimationFrame(() => {
      if (this.activePanel) {
        this.activePanel.scrollIntoView({ behavior: "smooth", block: "start" })
      }
      if (this.activeInningTab) {
        this.activeInningTab.scrollIntoView({ inline: "center", block: "nearest" })
      }
    })
  }

  render() {
    if (!this.hasPanelTarget) return

    this.panelTargets.forEach((panel) => {
      const showing =
        Number(panel.dataset.inning) === this.inningValue &&
        panel.dataset.half === this.halfValue
      panel.classList.toggle("hidden", !showing)
    })

    this.inningTabTargets.forEach((tab) => {
      this.setActive(tab, Number(tab.dataset.inning) === this.inningValue)
    })

    this.halfTabTargets.forEach((tab) => {
      this.setActive(tab, tab.dataset.half === this.halfValue)
    })

    this.persist()
  }

  setActive(tab, active) {
    tab.classList.toggle("tab-active", active)
    tab.setAttribute("aria-selected", active ? "true" : "false")
  }

  get defaultHalf() {
    return this.activeHalfValue || "batting"
  }

  get activePanel() {
    return this.panelTargets.find((panel) => !panel.classList.contains("hidden"))
  }

  get activeInningTab() {
    return this.inningTabTargets.find((tab) => Number(tab.dataset.inning) === this.inningValue)
  }

  // Saving an at-bat redirects to a full games#show render, so without this you
  // would be thrown back to the live inning every time you edited an earlier one.
  get storageKey() {
    return `scorebook:${this.gameIdValue}`
  }

  persist() {
    try {
      sessionStorage.setItem(
        this.storageKey,
        JSON.stringify({ inning: this.inningValue, half: this.halfValue })
      )
    } catch (error) {
      // Storage can be unavailable (private browsing, blocked site data).
    }
  }

  restore() {
    try {
      return JSON.parse(sessionStorage.getItem(this.storageKey)) || {}
    } catch (error) {
      return {}
    }
  }
}
