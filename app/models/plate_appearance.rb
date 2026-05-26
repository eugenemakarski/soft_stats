class PlateAppearance < ApplicationRecord
  belongs_to :game
  belongs_to :player

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
    lineout: 9,
    sac_fly: 10,
    sac_bunt: 11,
    double_play: 12,
    fielders_choice: 13,
    error: 14
  }

  validates :result, presence: true
end
