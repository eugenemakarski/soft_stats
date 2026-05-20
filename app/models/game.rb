class Game < ApplicationRecord
  belongs_to :season
  has_many :game_rosters


  enum :status, { not_started: 0, in_progress: 1, completed: 2 }
end
