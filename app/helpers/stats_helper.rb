module StatsHelper
  # Downward caret; .sort-icon styling (size, dim/active, rotate for ascending)
  # lives in app/assets/tailwind/application.css.
  SORT_ICON = <<~SVG.freeze
    <svg class="sort-icon" viewBox="0 0 10 6" fill="currentColor" aria-hidden="true"><path d="M0 0h10L5 6z"/></svg>
  SVG

  # A sortable column header for a .stats-table. The table wrapper supplies
  # data-controller="sortable-table"; these supply the click target.
  def stat_header(label, sort_type: "number", sticky: false, title: nil)
    tag.th(
      scope: "col",
      title: title,
      class: sticky ? "stats-sticky-col" : nil,
      data: {
        sortable_table_target: "header",
        sort_type: sort_type,
        action: "click->sortable-table#sort"
      }
    ) do
      tag.div(class: "flex items-center gap-1") do
        safe_join([ tag.span(label), SORT_ICON.html_safe ])
      end
    end
  end

  # Baseball-style rate: .333, 1.250
  def stat_rate(value)
    formatted = format("%.3f", value.to_f)
    formatted.start_with?("0.") ? formatted.sub(/\A0/, "") : formatted
  end

  # ERA-style rate: 4.29
  def stat_era(value)
    format("%.2f", value.to_f)
  end

  # "8–3", or "8–3–1" when there are ties.
  def record_text(record)
    parts = [ record[:wins], record[:losses] ]
    parts << record[:ties] if record[:ties].positive?
    parts.join("–")
  end

  OUTCOME_STYLES = {
    win: [ "W", "text-green-400" ],
    loss: [ "L", "text-red-400" ],
    tie: [ "T", "text-body" ]
  }.freeze

  # "W 12–8" for a scored game, nothing otherwise.
  def game_score_label(game)
    letter, color = OUTCOME_STYLES[game.outcome]
    return unless letter

    tag.span("#{letter} #{game.our_score}–#{game.their_score}",
      class: "font-heading font-bold text-lg tabular-nums whitespace-nowrap #{color}")
  end

  def chip_class(active)
    active ? "chip chip-active" : "chip"
  end
end
