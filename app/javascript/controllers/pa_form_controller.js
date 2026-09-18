// app/javascript/controllers/pa_form_controller.js
//
// The at-bat form: quick-pick result buttons, and showing the "who scored?"
// checkboxes only when RBI > 0.

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["rbiField", "runnersSection", "resultSelect"];

  connect() {
    this.toggleRunners();
  }

  // Sets the result select from a quick-pick button and fires change so anything
  // else listening to the select still sees it.
  pick(event) {
    if (!this.hasResultSelectTarget) return;

    this.resultSelectTarget.value = event.params.result;
    this.resultSelectTarget.dispatchEvent(
      new Event("change", { bubbles: true }),
    );
  }

  toggleRunners() {
    if (!this.hasRunnersSectionTarget || !this.hasRbiFieldTarget) return;

    const rbi = parseInt(this.rbiFieldTarget.value, 10);
    this.runnersSectionTarget.classList.toggle("hidden", !(rbi > 0));
  }
}
