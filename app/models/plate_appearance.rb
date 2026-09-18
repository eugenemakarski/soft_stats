class PlateAppearance < ApplicationRecord
  belongs_to :game
  belongs_to :player

  has_many :run

  enum :result, {
    single: 0,
    double: 1,
    triple: 2,
    home_run: 3,
    walk: 4,
    hbp: 5,
    strikeout: 6,
    groundout: 7,
    flyout: 8,
    popup: 9,
    sac_fly: 10,
    sac_bunt: 11,
    double_play: 12,
    fielders_choice: 13,
    error: 14,
    lineout: 15
  }

  validates :result, presence: true

  # Display labels. These exist because `humanize.titleize` produces "Hbp" and
  # "Fielders Choice", and the entry list sorts by the label the user actually
  # reads — so the labels have to be canonical before sorting means anything.
  RESULT_LABELS = {
    "single" => "Single",
    "double" => "Double",
    "triple" => "Triple",
    "home_run" => "Home Run",
    "walk" => "Walk",
    "hbp" => "Hit By Pitch",
    "strikeout" => "Strikeout",
    "groundout" => "Groundout",
    "flyout" => "Flyout",
    "lineout" => "Lineout",
    "popup" => "Popup",
    "sac_fly" => "Sac Fly",
    "sac_bunt" => "Sac Bunt",
    "double_play" => "Double Play",
    "fielders_choice" => "Fielder's Choice",
    "error" => "Error"
  }.freeze

  # Results that exist for stats purposes but aren't offered during entry.
  # NOTE: hbp is counted in PlayerSeasonStats#on_base_percentage but can't be
  # recorded while it's listed here, so OBP is missing that term.
  EXCLUDED_FROM_ENTRY = %w[hbp sac_bunt].freeze

  QUICK_RESULTS = %w[single double groundout flyout lineout].freeze

  # [label, stored enum name] pairs, sorted by label.
  def self.result_options
    (results.keys - EXCLUDED_FROM_ENTRY)
      .map { |name| [ result_label(name), name ] }
      .sort_by(&:first)
  end

  def self.result_label(name)
    RESULT_LABELS.fetch(name.to_s, name.to_s.humanize)
  end
end
